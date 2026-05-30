import { aiClient } from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';
import { getPrayerTimes } from '../../infrastructure/external/prayertime.client.js';
import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { ScheduleFocusSessionDTO } from '../../interfaces/dtos/AI.dto.js';
import { CreateSession } from '../sessions/CreateSession.js';

const PRAYER_WINDOW_MINUTES = 30;
const PRAYER_ORDER = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'] as const;

type PrayerName = (typeof PRAYER_ORDER)[number];

type PrayerWindow = {
  name: PrayerName;
  start: Date;
  end: Date;
};

const parsePrayerTime = (time: string, baseDate: Date): Date | null => {
  const match = time.trim().match(/^(\d{1,2}):(\d{2})/);
  if (!match) return null;

  const hour = Number(match[1]);
  const minute = Number(match[2]);
  if (!Number.isFinite(hour) || !Number.isFinite(minute)) return null;

  return new Date(
    baseDate.getFullYear(),
    baseDate.getMonth(),
    baseDate.getDate(),
    hour,
    minute,
    0,
    0,
  );
};

const buildPrayerWindows = (prayers: Record<PrayerName, string>, baseDate: Date): PrayerWindow[] =>
  PRAYER_ORDER
    .map((name) => {
      const start = parsePrayerTime(prayers[name], baseDate);
      if (!start) return null;

      return {
        name,
        start,
        end: new Date(start.getTime() + PRAYER_WINDOW_MINUTES * 60_000),
      };
    })
    .filter((window): window is PrayerWindow => window !== null)
    .sort((left, right) => left.start.getTime() - right.start.getTime());

const overlaps = (start: Date, end: Date, window: PrayerWindow): boolean =>
  start < window.end && end > window.start;

const alignSessionAroundPrayerWindows = (
  startTime: Date,
  durationMinutes: number,
  windows: PrayerWindow[],
) => {
  let sessionStart = new Date(startTime);
  let sessionEnd = new Date(sessionStart.getTime() + durationMinutes * 60_000);
  const protectedPrayerBlocks = new Set<PrayerName>();

  let adjusted = false;
  let shifted = true;
  while (shifted) {
    shifted = false;

    for (const window of windows) {
      if (!overlaps(sessionStart, sessionEnd, window)) continue;

      protectedPrayerBlocks.add(window.name);
      sessionStart = new Date(window.end);
      sessionEnd = new Date(sessionStart.getTime() + durationMinutes * 60_000);
      adjusted = true;
      shifted = true;
      break;
    }
  }

  return {
    startTime: sessionStart,
    endTime: sessionEnd,
    adjusted,
    protectedPrayerBlocks: [...protectedPrayerBlocks],
  };
};

export const ScheduleFocusSession = async (data: ScheduleFocusSessionDTO) => {
  if (!data.userid) throw new Error('User ID is required');

  const settings = await prisma.digitaldisciplinesettings.findUnique({
    where: { userid: data.userid },
    select: { faithmodeenabled: true },
  });

  const memory = await StudentMemoryRepository.findByUser(data.userid);
  const preferredTime = memory['preferred_study_time'] ?? 'morning';

  const pendingTasks = await prisma.task.findMany({
    where: {
      userid: data.userid,
      status: { in: ['PENDING', 'IN_PROGRESS'] },
    },
    orderBy: [{ priority: 'desc' }, { deadline: 'asc' }],
    take: 5,
  });

  const taskList = pendingTasks.map(t =>
    `- ID: ${t.taskid} | ${t.title} | Priority: ${t.priority}/3 | Deadline: ${t.deadline ? new Date(t.deadline).toLocaleDateString() : 'None'}`
  ).join('\n');

  const prompt = `A student wants to start a focus session. Suggest which task to focus on and the best duration.

Pending tasks:
${taskList || 'No pending tasks'}

Preferred study time: ${preferredTime}
Requested duration: ${data.durationMinutes ? `${data.durationMinutes} minutes` : 'Not specified'}

Return a JSON object with:
- taskid: the task ID to focus on (or null if no tasks)
- durationMinutes: recommended duration — 25, 50, or 90
- reason: one sentence explaining why

Return ONLY valid JSON, no explanation.`;

  const model = resolveChatModel();
  let raw = '{}';

  try {
    if (aiClient.isClaude) {
      const response = await aiClient.claude.messages.create({
        model,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 150,
      });
      const textBlock = response.content?.[0] as any;
      raw = (textBlock?.type === 'text' ? textBlock.text : null) ?? '{}';
    } else {
      const response = await aiClient.openai.chat.completions.create({
        model,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 150,
      });
      raw = response.choices[0]?.message?.content ?? '{}';
    }
  } catch (error) {
    console.error('Focus session scheduling error:', error);
  }

  const clean = raw.replace(/```json|```/g, '').trim();
  const suggestion = JSON.parse(clean);

  const durationMinutes = data.durationMinutes ?? suggestion.durationMinutes ?? 25;
  const faithmode = data.faithmode ?? settings?.faithmodeenabled ?? false;

  let start = new Date();
  let end = new Date(start.getTime() + durationMinutes * 60_000);
  let prayerWindowInfo: {
    adjusted: boolean;
    protectedPrayerBlocks: PrayerName[];
    prayerTimes: Record<PrayerName, string>;
  } | null = null;

  if (faithmode) {
    const prayers = await getPrayerTimes(data.city ?? 'Bejaia', data.country ?? 'Algeria');
    const windows = buildPrayerWindows(prayers, start);
    const aligned = alignSessionAroundPrayerWindows(start, durationMinutes, windows);
    start = aligned.startTime;
    end = aligned.endTime;
    prayerWindowInfo = {
      adjusted: aligned.adjusted,
      protectedPrayerBlocks: aligned.protectedPrayerBlocks,
      prayerTimes: prayers,
    };
  }

  const focusSession = await CreateSession({
    userid: data.userid,
    starttime: start,
    endtime: end,
    allowbreakminutes: 5,
  });

  const selectedTaskId = data.taskid ?? suggestion.taskid ?? null;
  if (selectedTaskId) {
    await prisma.sessiontask.create({
      data: { taskid: selectedTaskId, sessionid: focusSession.sessionid },
    });
  }

  return {
    sessionid: focusSession.sessionid,
    suggestedTaskid: selectedTaskId,
    durationMinutes,
    reason: suggestion.reason ?? 'Focus on your highest priority task.',
    message: 'Focus session created! Open Neurova to start.',
    ...(prayerWindowInfo
      ? {
          faithModeApplied: true,
          adjustedForPrayer: prayerWindowInfo.adjusted,
          protectedPrayerBlocks: prayerWindowInfo.protectedPrayerBlocks,
          prayerTimes: prayerWindowInfo.prayerTimes,
          scheduledStartTime: start,
          scheduledEndTime: end,
          message: prayerWindowInfo.adjusted
            ? 'Focus session created around prayer times. Open Neurova to start.'
            : 'Focus session created with Faith Mode enabled. Open Neurova to start.',
        }
      : {}),
  };
};
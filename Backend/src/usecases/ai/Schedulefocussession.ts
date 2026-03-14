import openai from '../../infrastructure/ai/openai.client.js';
import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { ScheduleFocusSessionDTO } from '../../interfaces/dtos/AI.dto.js';
import { CreateSession } from '../sessions/CreateSession.js';

export const ScheduleFocusSession = async (data: ScheduleFocusSessionDTO) => {
  if (!data.userid) throw new Error('User ID is required');

  // Load memory to respect user study preferences.
  const memory = await StudentMemoryRepository.findByUser(data.userid);
  const preferredTime = memory['preferred_study_time'] ?? 'morning';

  // Pick from pending tasks, sorted by urgency.
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

  // Ask the model to suggest a task and session duration.
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

  const response = await openai.chat.completions.create({
    model: 'gemini-2.0-flash',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 150,
  });

  const raw = response.choices[0]?.message?.content ?? '{}';
  const clean = raw.replace(/```json|```/g, '').trim();
  const suggestion = JSON.parse(clean);

  // Create the session through the existing session usecase.
  const durationMinutes = data.durationMinutes ?? suggestion.durationMinutes ?? 25;
  const start = new Date();
  const end = new Date(start.getTime() + durationMinutes * 60_000);

  const focusSession = await CreateSession({
    userid: data.userid,
    starttime: start,
    endtime: end,
    allowbreakminutes: 5,
  });

  const selectedTaskId = data.taskid ?? suggestion.taskid ?? null;
  if (selectedTaskId) {
    await prisma.task_focussession.create({
      data: { taskid: selectedTaskId, sessionid: focusSession.sessionid },
    });
  }

  return {
    sessionid: focusSession.sessionid,
    suggestedTaskid: selectedTaskId,
    durationMinutes,
    reason: suggestion.reason ?? 'Focus on your highest priority task.',
    message: 'Focus session created! Open Neurova to start.',
  };
};
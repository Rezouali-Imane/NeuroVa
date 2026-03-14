import openai from '../../infrastructure/ai/openai.client.js';
import { getPrayerTimes } from '../../infrastructure/external/prayertime.client.js';
import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { GenerateStudyPlanDTO } from '../../interfaces/dtos/AI.dto.js';

export const GenerateStudyPlan = async (data: GenerateStudyPlanDTO) => {
  if (!data.userid) throw new Error('User ID is required');

  // 1. Fetch tasks
  const tasks = await prisma.task.findMany({
    where: { userid: data.userid, status: { in: ['PENDING', 'IN_PROGRESS'] } },
    orderBy: { deadline: 'asc' },
  });

  if (tasks.length === 0) {
    return { plan: 'You have no pending tasks! Add some tasks first so I can create a study plan for you.' };
  }

  // 2. Load memory for personalization
  const memory = await StudentMemoryRepository.findByUser(data.userid);

  // 3. Format task list
  const taskList = tasks.map(t =>
    `- ${t.title} | Category: ${t.category} | Priority: ${t.priority}/3 | Deadline: ${t.deadline ? new Date(t.deadline).toLocaleDateString() : 'No deadline'} | Status: ${t.status}`
  ).join('\n');

  // 4. Prayer times if Faith Mode
  let prayerBlock = '';
  if (data.faithmode) {
    const prayers = await getPrayerTimes(data.city ?? 'Bejaia', data.country ?? 'Algeria');
    prayerBlock = `\n\nPrayer times — do not schedule study blocks during these:
- Fajr: ${prayers.Fajr}
- Dhuhr: ${prayers.Dhuhr}
- Asr: ${prayers.Asr}
- Maghrib: ${prayers.Maghrib}
- Isha: ${prayers.Isha}`;
  }

  // 5. Student profile block
  const profileBlock = [
    memory['major'] && `Major: ${memory['major']}`,
    memory['university'] && `University: ${memory['university']}`,
    memory['preferred_study_time'] && `Preferred study time: ${memory['preferred_study_time']}`,
    memory['weak_subjects'] && `Weak subjects (give extra time): ${memory['weak_subjects']}`,
  ].filter(Boolean).join('\n');


  const prompt = `You are an academic study planner. Generate a structured 7-day study plan.

Student Profile:
${profileBlock || 'No profile data yet'}

Pending Tasks:
${taskList}${prayerBlock}

Create a day-by-day plan that:
1. Prioritizes by deadline and priority (3 = highest)
2. Gives extra time to weak subjects
3. Uses Pomodoro blocks: 25min study, 5min break
4. Matches preferred study time if known
${data.faithmode ? '5. Avoids all prayer times' : ''}

Format: **Day 1 — [Date]** then bullet points per time block.`;

 
  const response = await openai.chat.completions.create({
    model: 'gemini-2.0-flash',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1500,
  });

  const plan = response.choices[0]?.message?.content ?? 'Could not generate study plan.';
  return { plan };
};
import openai from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';
import prisma from '../../infrastructure/database/prisma.client.js';


export const DetectAndCreateTasks = async (
  userid: string,
  userMessage: string
): Promise<void> => {
  try {
    let defaultList = await prisma.tasklist.findFirst({
      where: { userid },
      orderBy: { createdat: 'asc' },
    });

    if (!defaultList) {
      defaultList = await prisma.tasklist.create({
        data: { userid, name: 'General' },
      });
    }

    const prompt = `You are a task extraction system for a student productivity app.

Analyze this student message and extract any tasks, assignments, or to-dos mentioned:
"${userMessage}"

Return a JSON array of tasks found. Each task:
- title: short task name (max 60 chars)
- category: one of ACADEMIC, PERSONAL, WORK, HEALTH, OTHER
- priority: 1 (low), 2 (medium), 3 (high)
- deadline: ISO date string if a date is mentioned, otherwise null

Rules:
- Only extract EXPLICIT tasks the student needs to do
- If no tasks mentioned, return []
- Return ONLY valid JSON array, no explanation, no markdown

Example: [{"title": "Study for algorithms exam", "category": "ACADEMIC", "priority": 3, "deadline": "2026-03-20T00:00:00.000Z"}]`;

    const response = await openai.chat.completions.create({
      model: resolveChatModel(),
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 300,
    });

    const raw = response.choices[0]?.message?.content ?? '[]';
    const clean = raw.replace(/```json|```/g, '').trim();
    const tasks = JSON.parse(clean);

    if (!Array.isArray(tasks) || tasks.length === 0) return;

    for (const task of tasks) {
      if (!task.title) continue;
      await prisma.task.create({
        data: {
          userid,
          listid: defaultList.listid,
          title: task.title,
          category: task.category ?? 'ACADEMIC',
          priority: task.priority ?? 1,
          status: 'PENDING',
          deadline: task.deadline ? new Date(task.deadline) : null,
          description: 'Auto-created by Neurova AI from your conversation',
        },
      });
    }
  } catch {
  }
};
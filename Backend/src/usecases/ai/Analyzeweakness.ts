import openai from '../../infrastructure/ai/openai.client.js';
import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { AnalyzeWeaknessDTO } from '../../interfaces/dtos/AI.dto.js';

export const AnalyzeWeakness = async (data: AnalyzeWeaknessDTO) => {
  if (!data.userid) throw new Error('User ID is required');

  // 1. Fetch all tasks
  const tasks = await prisma.task.findMany({ where: { userid: data.userid } });

  if (tasks.length === 0) {
    return { analysis: 'No task history yet. Complete some tasks so I can analyze your patterns!' };
  }

  // 2. Load memory
  const memory = await StudentMemoryRepository.findByUser(data.userid);
  const name = memory['name'] ?? 'Student';
  const major = memory['major'] ?? '';

  // 3. Group by category + status
  const summary: Record<string, { total: number; completed: number; overdue: number; pending: number }> = {};

  for (const task of tasks) {
    const cat = task.category ?? 'OTHER';
    if (!summary[cat]) summary[cat] = { total: 0, completed: 0, overdue: 0, pending: 0 };
    summary[cat].total++;
    if (task.status === 'COMPLETED') summary[cat].completed++;
    else if (task.status === 'OVERDUE') summary[cat].overdue++;
    else summary[cat].pending++;
  }

  // 4. Format stats
  const statsBlock = Object.entries(summary).map(([cat, s]) => {
    const rate = s.total > 0 ? Math.round((s.completed / s.total) * 100) : 0;
    return `${cat}: ${s.total} total | ${s.completed} completed (${rate}%) | ${s.overdue} overdue | ${s.pending} pending`;
  }).join('\n');

  const overdueList = tasks
    .filter(t => t.status === 'OVERDUE')
    .map(t => `- ${t.title} (${t.category})`)
    .join('\n');

  // 5. Prompt
  const prompt = `Analyze the academic performance of ${name}${major ? ` studying ${major}` : ''}.

Task statistics by category:
${statsBlock}

Overdue tasks:
${overdueList || 'None'}

Provide:
1. **Performance Summary** — overall completion assessment
2. **Weakness Areas** — top 2-3 categories with poor rates
3. **Pattern Analysis** — possible causes
4. **Action Plan** — 3 specific actionable steps
5. **Encouragement** — short motivating message to ${name}

Use markdown. Be specific and personal.`;

  // 6. Call Gemini
  const response = await openai.chat.completions.create({
    model: 'gemini-2.0-flash',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 800,
  });

  const analysis = response.choices[0]?.message?.content ?? 'Could not generate analysis.';

  // 7. Save weak subjects back to memory
  const weakCategories = Object.entries(summary)
    .filter(([, s]) => s.total > 0 && (s.overdue / s.total) > 0.3)
    .map(([cat]) => cat).join(', ');

  if (weakCategories) {
    await StudentMemoryRepository.upsert(data.userid, 'weak_subjects', weakCategories);
  }

  return { analysis };
};
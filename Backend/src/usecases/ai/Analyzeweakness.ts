import openai from '../../infrastructure/ai/openai.client.js';
import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { AnalyzeWeaknessDTO } from '../../interfaces/dtos/AI.dto.js';

export const AnalyzeWeakness = async (data: AnalyzeWeaknessDTO) => {
  if (!data.userid) throw new Error('User ID is required');

  // Pull this user's task history.
  const tasks = await prisma.task.findMany({ where: { userid: data.userid } });

  if (tasks.length === 0) {
    return { analysis: 'No task history yet. Complete some tasks so I can analyze your patterns!' };
  }

  // Load saved profile details for prompt context.
  const memory = await StudentMemoryRepository.findByUser(data.userid);
  const name = memory['name'] ?? 'Student';
  const major = memory['major'] ?? '';

  // Summarize completion stats by category and status.
  const summary: Record<string, { total: number; completed: number; overdue: number; pending: number }> = {};

  for (const task of tasks) {
    const cat = task.category ?? 'OTHER';
    if (!summary[cat]) summary[cat] = { total: 0, completed: 0, overdue: 0, pending: 0 };
    summary[cat].total++;
    if (task.status === 'COMPLETED') summary[cat].completed++;
    else if (task.status === 'OVERDUE') summary[cat].overdue++;
    else summary[cat].pending++;
  }

  // Build a compact stats block for the model.
  const statsBlock = Object.entries(summary).map(([cat, s]) => {
    const rate = s.total > 0 ? Math.round((s.completed / s.total) * 100) : 0;
    return `${cat}: ${s.total} total | ${s.completed} completed (${rate}%) | ${s.overdue} overdue | ${s.pending} pending`;
  }).join('\n');

  const overdueList = tasks
    .filter(t => t.status === 'OVERDUE')
    .map(t => `- ${t.title} (${t.category})`)
    .join('\n');

  // Ask the model for a structured weakness review.
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

  // Generate final analysis text.
  const response = await openai.chat.completions.create({
    model: 'gemini-2.0-flash',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 800,
  });

  const analysis = response.choices[0]?.message?.content ?? "I couldn't finish the analysis right now. Try again in a moment.";

  // Save likely weak categories for future personalization.
  const weakCategories = Object.entries(summary)
    .filter(([, s]) => s.total > 0 && (s.overdue / s.total) > 0.3)
    .map(([cat]) => cat).join(', ');

  if (weakCategories) {
    await StudentMemoryRepository.upsert(data.userid, 'weak_subjects', weakCategories);
  }

  return { analysis };
};
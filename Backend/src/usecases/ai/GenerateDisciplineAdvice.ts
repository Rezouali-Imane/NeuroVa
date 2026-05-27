import prisma from '../../infrastructure/database/prisma.client.js';
import { aiClient } from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';

export const GenerateDisciplineAdvice = async (userid: string) => {
  try {
    // Get user's discipline data
    const disciplineScore = await prisma.disciplinescore.findFirst({
      where: { userid },
      orderBy: { scoredate: 'desc' },
      take: 1,
    });

    const recentUsageLogs = await prisma.usagelog.findMany({
      where: { userid },
      orderBy: { logdate: 'desc' },
      take: 30,
    });

    const settings = await prisma.digitaldisciplinesettings.findUnique({
      where: { userid },
      include: {
        blockedapp: true,
        blockedwebsite: true,
        usagelimit: true,
      },
    });

    // Calculate patterns
    const blockedCount = recentUsageLogs.filter((log) => log.wasblocked).length;
    const totalMinutesWasted = recentUsageLogs.reduce((sum, log) => sum + log.usageminutes, 0);
    const avgDailyWaste = Math.round(totalMinutesWasted / 30);
    const blockedApps = new Set(
      recentUsageLogs
        .filter((log) => log.wasblocked)
        .map((log) => log.appname)
        .filter(Boolean),
    );

    // Build prompt for Claude
    const prompt = `
You are a discipline coach helping a student improve their digital discipline and focus.

Student's Digital Discipline Report:
- Discipline Score: ${disciplineScore?.score ?? 0}/100
- Violations Last 30 Days: ${disciplineScore?.violationcount ?? 0}
- Current Streak: ${disciplineScore?.streak ?? 0} days
- Times Blocked by Limits: ${blockedCount}
- Average Daily Wasted Time: ${avgDailyWaste} minutes
- Most Blocked Apps: ${Array.from(blockedApps).slice(0, 5).join(', ') || 'None'}
- Websites on Blocklist: ${settings?.blockedwebsite?.length ?? 0}
- Active Usage Limits: ${settings?.usagelimit?.length ?? 0}

Based on this data, provide:
1. Current discipline level assessment (Poor/Fair/Good/Excellent)
2. Top 3 concrete actions to improve discipline immediately
3. Specific recommendations for app/website blocking strategy
4. A 7-day challenge to break distraction habits
5. Motivation and encouragement (be supportive but honest)

Keep response concise and actionable, focused on practical next steps.
    `.trim();

    let advice = 'Unable to generate discipline advice';

    const model = resolveChatModel();

    if (aiClient.isClaude) {
      const response = await aiClient.claude.messages.create({
        model,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 1500,
      });

      const textBlock = response.content?.[0] as any;
      const claudeText = textBlock?.type === 'text' ? textBlock.text : null;
      advice = claudeText ?? advice;
    } else {
      const response = await aiClient.openai.chat.completions.create({
        model,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 1500,
      });

      advice = response.choices[0]?.message?.content ?? advice;
    }

    return {
      success: true,
      advice,
      score: disciplineScore?.score ?? 0,
      generatedAt: new Date(),
    };
  } catch (error) {
    console.error('Error generating discipline advice:', error);
    throw error;
  }
};

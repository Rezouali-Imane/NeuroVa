import { aiClient } from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';

const AI_PROVIDER = (process.env.AI_PROVIDER || 'claude').toLowerCase();
const ENABLE_MEMORY_EXTRACTION = (process.env.CLAUDE_ENABLE_MEMORY_EXTRACTION || 'true').toLowerCase() === 'true';

const MEMORY_KEYS = [
  'name',
  'major',
  'university',
  'year',
  'weak_subjects',
  'goals',
  'exam_dates',
  'preferred_study_time',
];

export const ExtractAndSaveMemory = async (
  userid: string,
  userMessage: string,
  existingMemory: Record<string, string>
): Promise<void> => {
  if (!ENABLE_MEMORY_EXTRACTION) return;

  try {
    const alreadyKnown = Object.entries(existingMemory)
      .map(([k, v]) => `${k}: ${v}`)
      .join('\n');

    const prompt = `You are a memory extraction system. Extract factual information about a student from their message.

Message: "${userMessage}"

Already known:
${alreadyKnown || 'Nothing yet'}

Extract ONLY new facts not already known. Return a JSON object with any of these keys that are clearly mentioned:
${MEMORY_KEYS.join(', ')}

Rules:
- Only include keys with clear, explicit information
- If nothing new, return {}
- Return ONLY valid JSON, no explanation, no markdown`;

    const model = resolveChatModel();
    let raw = '{}';

    try {
      if (aiClient.isClaude) {
        const response = await aiClient.claude.messages.create({
          model,
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 200,
        });
        const textBlock = response.content?.[0] as any;
        raw = (textBlock?.type === 'text' ? textBlock.text : null) ?? '{}';
      } else {
        const response = await aiClient.openai.chat.completions.create({
          model,
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 200,
        });
        raw = response.choices[0]?.message?.content ?? '{}';
      }
    } catch (error) {
      console.error('Memory extraction API error:', error);
      return;
    }

    const clean = raw.replace(/```json|```/g, '').trim();
    const extracted = JSON.parse(clean);

    for (const [key, value] of Object.entries(extracted)) {
      if (MEMORY_KEYS.includes(key) && typeof value === 'string' && value.trim()) {
        await StudentMemoryRepository.upsert(userid, key, value.trim());
      }
    }
  } catch {
  }
};
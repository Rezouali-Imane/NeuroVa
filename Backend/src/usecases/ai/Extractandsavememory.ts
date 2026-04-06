import openai from '../../infrastructure/ai/openai.client.js';
import { resolveChatModel } from '../../infrastructure/ai/model-resolver.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';

const AI_PROVIDER = (process.env.AI_PROVIDER || 'gemini').toLowerCase();
const ENABLE_OLLAMA_MEMORY_EXTRACTION = (process.env.OLLAMA_ENABLE_MEMORY_EXTRACTION || 'false').toLowerCase() === 'true';

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
  if (AI_PROVIDER === 'ollama' && !ENABLE_OLLAMA_MEMORY_EXTRACTION) return;

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

    const response = await openai.chat.completions.create({
      model: resolveChatModel(),
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 200,
    });

    const raw = response.choices[0]?.message?.content ?? '{}';
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
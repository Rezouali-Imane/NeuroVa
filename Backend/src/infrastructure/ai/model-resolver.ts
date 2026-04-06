import 'dotenv/config';

const AI_PROVIDER = (process.env.AI_PROVIDER || 'gemini').toLowerCase();

export const resolveChatModel = (): string => {
  if (AI_PROVIDER === 'ollama') {
    return process.env.OLLAMA_MODEL?.trim() || 'llama3.2:1b';
  }

  if (AI_PROVIDER === 'openrouter') {
    return process.env.OPENROUTER_MODEL?.trim() || 'qwen/qwen-2.5-7b-instruct:free';
  }

  return process.env.GEMINI_MODEL?.trim() || 'gemini-1.5-flash';
};

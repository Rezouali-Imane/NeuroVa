import OpenAI from 'openai';
import 'dotenv/config';

const aiProvider = (process.env.AI_PROVIDER || 'gemini').toLowerCase();
const isOpenRouter = aiProvider === 'openrouter';
const isOllama = aiProvider === 'ollama';

const normalizeOllamaBaseUrl = (url?: string): string => {
  const raw = (url || 'http://127.0.0.1:11434').trim().replace(/\/+$/, '');
  return raw.endsWith('/v1') ? raw : `${raw}/v1`;
};

const baseURL = isOllama
  ? normalizeOllamaBaseUrl(process.env.OLLAMA_BASE_URL)
  : isOpenRouter
      ? 'https://openrouter.ai/api/v1'
      : 'https://generativelanguage.googleapis.com/v1beta/openai/';

const apiKey = isOllama
  ? (process.env.OLLAMA_API_KEY?.trim() || 'ollama')
  : isOpenRouter
      ? process.env.OPENROUTER_API_KEY?.trim()
      : process.env.GEMINI_API_KEY?.trim();

const openai = new OpenAI({
  apiKey,
  baseURL,
});

export default openai;
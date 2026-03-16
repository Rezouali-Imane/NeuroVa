import OpenAI from 'openai';
import 'dotenv/config';

const aiProvider = (process.env.AI_PROVIDER || 'gemini').toLowerCase();
const isOpenRouter = aiProvider === 'openrouter';

const openai = new OpenAI({
  apiKey: (isOpenRouter ? process.env.OPENROUTER_API_KEY : process.env.GEMINI_API_KEY)?.trim(),
  baseURL: isOpenRouter
    ? 'https://openrouter.ai/api/v1'
    : 'https://generativelanguage.googleapis.com/v1beta/openai/',
});

export default openai;
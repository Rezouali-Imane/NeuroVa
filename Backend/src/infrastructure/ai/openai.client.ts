import 'dotenv/config';
import Anthropic from '@anthropic-ai/sdk';
import OpenAI from 'openai';

const aiProvider = (process.env.AI_PROVIDER || 'claude').toLowerCase();
const isClaude = aiProvider === 'claude';
const isOpenRouter = aiProvider === 'openrouter';
const isOllama = aiProvider === 'ollama';

// Get and validate Claude API key
const claudeApiKey = process.env.CLAUDE_API_KEY?.trim();

console.log('🔍 Claude Configuration Loaded');
console.log(`  - AI_PROVIDER: ${aiProvider}`);
console.log(`  - API Key Present: ${claudeApiKey ? '✅ Yes' : '❌ No'}`);

if (isClaude && !claudeApiKey) {
  console.warn('⚠️  WARNING: CLAUDE_API_KEY not set - AI features will fail when used');
}

const normalizeOllamaBaseUrl = (url?: string): string => {
  const raw = (url || 'http://127.0.0.1:11434').trim().replace(/\/+$/, '');
  return raw.endsWith('/v1') ? raw : `${raw}/v1`;
};

// Initialize Claude client (PRIMARY PROVIDER)
let claudeClient: any = null;
try {
  if (!claudeApiKey && isClaude) {
    console.warn('⚠️  Claude API key is missing - will fail when AI is used');
    // Create a client that will fail gracefully when used
    claudeClient = {
      messages: {
        create: async () => {
          throw new Error('CLAUDE_API_KEY not configured. Please add it to .env file');
        },
      },
    };
  } else {
    claudeClient = new Anthropic({
      apiKey: claudeApiKey,
      timeout: 35000,
    });
    console.log('✅ Claude client initialized successfully');
  }
} catch (error: any) {
  console.error('❌ Failed to initialize Claude client:', error.message);
}

// Initialize OpenAI/other clients (fallback & Whisper transcription)
let openai: any = null;

try {
  const baseURL = isOllama
    ? normalizeOllamaBaseUrl(process.env.OLLAMA_BASE_URL)
    : isOpenRouter
        ? 'https://openrouter.ai/api/v1'
        : isClaude
            ? 'https://api.openai.com/v1' // Fallback for Whisper
            : 'https://generativelanguage.googleapis.com/v1beta/openai/';

  const apiKey = isOllama
    ? (process.env.OLLAMA_API_KEY?.trim() || 'ollama')
    : isOpenRouter
        ? process.env.OPENROUTER_API_KEY?.trim()
        : isClaude
            ? process.env.OPENAI_API_KEY?.trim() // Optional for Whisper
            : process.env.GEMINI_API_KEY?.trim();

  if (apiKey) {
    openai = new OpenAI({
      apiKey,
      baseURL,
    });
  } else if (!isClaude) {
    console.warn(`⚠️  No API key found for provider: ${aiProvider}. Falling back to Claude.`);
  }
} catch (error: any) {
  console.warn(`⚠️  Failed to initialize fallback AI client: ${error.message}. Using Claude as primary.`);
}

// If OpenAI initialization failed, create a dummy client for transcription
if (!openai) {
  openai = new OpenAI({
    apiKey: 'dummy-key-for-transcription',
  });
}

// Unified AI client wrapper
export const aiClient = {
  isClaude,
  claude: claudeClient,
  openai,
  provider: aiProvider,
};

export default aiClient;
import { aiClient } from '../../infrastructure/ai/openai.client.js';
import type { ChatCompletionMessageParam, ChatCompletionTool } from 'openai/resources/chat/completions';
import type { MessageParam } from '@anthropic-ai/sdk/resources/messages';
import prisma from '../../infrastructure/database/prisma.client.js';
import { getEmbedding } from '../../infrastructure/embedding.client.js';
import { searchSimilarChunks } from '../../infrastructure/supabase.vector.client.js';
import {
  ChatHistoryRepository,
  AssistantRepository,
  StudentMemoryRepository,
} from '../../interfaces/repositories/AIRepositories.js';
import type { SendMessageDTO } from '../../interfaces/dtos/AI.dto.js';
import { CreateTask } from '../tasks/CreateTask.js';
import { UpdateTask } from '../tasks/UpdateTask.js';
import { DeleteTask } from '../tasks/DeleteTask.js';
import { GetTasks } from '../tasks/GetTasks.js';
import { UpdateTaskStatus } from '../tasks/UpdateTaskStatus.js';
import { CreateTaskList } from '../tasks/CreateTaskList.js';
import { GetTaskList } from '../tasks/GetTaskList.js';
import { UpdateTaskList } from '../tasks/UpdateTaskList.js';
import { CreateSession } from '../sessions/CreateSession.js';
import { StartSession } from '../sessions/StartSession.js';
import { EndSession } from '../sessions/EndSession.js';
import { GetSessions } from '../sessions/GetSession.js';
import { TaskCategory, TaskStatus } from '../../entities/Task.js';
import type { CreateTaskDTO, UpdateTaskDTO } from '../../interfaces/dtos/Task.dto.js';
import type { UpdateTaskListDTO } from '../../interfaces/dtos/TaskList.dto.js';
import { ExtractAndSaveMemory } from './Extractandsavememory.js';


const detectLanguage = (text: string): string => {
  if (/[\u0600-\u06FF]/.test(text)) return 'Arabic';
  const frenchWords = ['je', 'tu', 'il', 'nous', 'vous', 'est', 'avec', 'pour', 'dans', 'comment', 'pourquoi'];
  if (text.toLowerCase().split(/\s+/).filter(w => frenchWords.includes(w)).length >= 2) return 'French';
  return 'English';
};

const buildSystemPrompt = (
  memory: Record<string, string>,
  ragContext: string,
  language: string,
  faithmode: boolean
): string => {
  const profileParts = [
    memory['name'] && `Name: ${memory['name']}`,
    memory['major'] && `Major: ${memory['major']}`,
    memory['university'] && `University: ${memory['university']}`,
    memory['year'] && `Year: ${memory['year']}`,
    memory['weak_subjects'] && `Weak subjects: ${memory['weak_subjects']}`,
    memory['goals'] && `Goals: ${memory['goals']}`,
  ].filter(Boolean);

  const profileBlock = profileParts.length > 0
    ? `\n\nStudent Profile:\n${profileParts.map(p => `- ${p}`).join('\n')}`
    : '';

  const ragBlock = ragContext
    ? `\n\n--- CONTENT FROM STUDENT'S DOCUMENTS ---\n${ragContext}\n--- END OF DOCUMENT CONTENT ---\n\nUse the above content to answer when relevant.`
    : '';

  const faithBlock = faithmode
    ? `\n\nFaith Mode ON: Be mindful of Islamic values. Encourage prayer breaks. Use uplifting language.`
    : '';

  const langBlock = language !== 'English'
    ? `\n\nIMPORTANT: Respond ONLY in ${language}.`
    : '';

  return `You are Neurova, an intelligent AI academic assistant built into a student productivity app.
Personality: warm, encouraging, practical, and clear.
Help with: concept explanations, study strategies, problem solving, exam prep, and academic planning.
Always format responses clearly using markdown (bold, bullet points, code blocks when relevant).

You can perform actions through tools for:
- Task management: create/update/delete/list tasks, update task status
- Task lists: create/update/list
- Focus sessions: create/list/start/end

When a user asks for an action, call the right tool first, then explain the result in a natural and friendly way.${profileBlock}${ragBlock}${faithBlock}${langBlock}`;
};

const toTaskCategory = (value: unknown): TaskCategory | undefined => {
  if (typeof value !== 'string') return undefined;
  const normalized = value.toUpperCase();
  if (Object.values(TaskCategory).includes(normalized as TaskCategory)) {
    return normalized as TaskCategory;
  }
  return undefined;
};

const toTaskStatus = (value: unknown): TaskStatus | undefined => {
  if (typeof value !== 'string') return undefined;
  const normalized = value.toUpperCase();
  if (Object.values(TaskStatus).includes(normalized as TaskStatus)) {
    return normalized as TaskStatus;
  }
  return undefined;
};

const parseToolArguments = (input: string): Record<string, unknown> => {
  try {
    const parsed = JSON.parse(input);
    return typeof parsed === 'object' && parsed !== null ? parsed as Record<string, unknown> : {};
  } catch {
    return {};
  }
};

const parseInlineToolCalls = (content: string): Array<{
  id: string;
  type: 'function';
  function: { name: string; arguments: string };
}> => {
  const matches = content.matchAll(/<tool_call>\s*([\s\S]*?)\s*<\/tool_call>/g);
  const parsedCalls: Array<{
    id: string;
    type: 'function';
    function: { name: string; arguments: string };
  }> = [];

  let index = 0;
  for (const match of matches) {
    const payload = match[1]?.trim();
    if (!payload) continue;

    try {
      const parsed = JSON.parse(payload) as { name?: unknown; arguments?: unknown };
      if (typeof parsed.name !== 'string' || !parsed.name.trim()) continue;

      const argsObject =
        typeof parsed.arguments === 'object' && parsed.arguments !== null
          ? parsed.arguments
          : {};

      parsedCalls.push({
        id: `inline_tool_${index++}`,
        type: 'function',
        function: {
          name: parsed.name,
          arguments: JSON.stringify(argsObject),
        },
      });
    } catch {
      continue;
    }
  }

  return parsedCalls;
};

const normalizeText = (value: string): string =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const pickFirstString = (...values: unknown[]): string | undefined => {
  for (const value of values) {
    if (typeof value === 'string' && value.trim()) return value.trim();
  }
  return undefined;
};

const extractEntityQueryFromContent = (content: string, entity: 'task' | 'tasklist'): string | undefined => {
  const quoted = content.match(/"([^"]{2,})"|'([^']{2,})'/);
  const quotedValue = quoted?.[1] ?? quoted?.[2];
  if (quotedValue?.trim()) return quotedValue.trim();

  if (entity === 'task') {
    const m = content.match(/(?:task\s+named|task\s+called|task\s+title\s+is|task)\s+([^.,;\n]+?)(?:\s+(?:to|as|with|status|priority|deadline|description)\b|$)/i);
    if (m?.[1]?.trim()) return m[1].trim();
  } else {
    const m = content.match(/(?:task\s*list|tasklist)\s+(?:named|called)?\s*([^.,;\n]+?)(?:\s+(?:to|as|with|name|title|rename|update)\b|$)/i);
    if (m?.[1]?.trim()) return m[1].trim();
  }

  return undefined;
};

const resolveTaskIdForUser = async (userid: string, query: string): Promise<string | null> => {
  const tasks = await GetTasks(userid);
  const normalizedQuery = normalizeText(query);
  if (!normalizedQuery) return null;

  const exact = tasks.find((task) => normalizeText(task.title) === normalizedQuery);
  if (exact) return exact.taskid;

  const contains = tasks.find((task) => normalizeText(task.title).includes(normalizedQuery));
  if (contains) return contains.taskid;

  const reverseContains = tasks.find((task) => normalizedQuery.includes(normalizeText(task.title)));
  if (reverseContains) return reverseContains.taskid;

  return null;
};

const resolveTaskListIdForUser = async (userid: string, query: string): Promise<string | null> => {
  const lists = await GetTaskList(userid);
  const normalizedQuery = normalizeText(query);
  if (!normalizedQuery) return null;

  const exact = lists.find((list) => normalizeText(list.name) === normalizedQuery);
  if (exact) return exact.listid;

  const contains = lists.find((list) => normalizeText(list.name).includes(normalizedQuery));
  if (contains) return contains.listid;

  const reverseContains = lists.find((list) => normalizedQuery.includes(normalizeText(list.name)));
  if (reverseContains) return reverseContains.listid;

  return null;
};

const isActionIntent = (content: string): boolean => {
  const text = content.toLowerCase();
  const hasActionVerb = /\b(create|add|schedule|start|end|delete|remove|update|list|show)\b/.test(text);
  const hasSupportedEntity = /\btask|tasks|task list|tasklist|focus session|session|focus\b/.test(text);
  return hasActionVerb && hasSupportedEntity;
};

const isUpdateIntent = (content: string): boolean => {
  const text = content.toLowerCase();
  const hasUpdateVerb = /\b(update|rename|change|edit|mark|set)\b/.test(text);
  const hasUpdatableEntity = /\btask|tasks|task list|tasklist|status|title|description|deadline|priority|name\b/.test(text);
  return hasUpdateVerb && hasUpdatableEntity;
};

const UPDATE_ONLY_TOOL_NAMES = new Set([
  'update_task',
  'update_task_status',
  'update_task_list',
  'list_tasks',
  'list_task_lists',
]);

const sleep = async (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

// Helper to extract text content from Claude or OpenAI response
const getResponseText = (response: any): string | null => {
  if (aiClient.isClaude) {
    return response.content?.[0]?.text ?? null;
  }
  return response.choices?.[0]?.message?.content ?? null;
};

// Helper to extract tool calls from Claude or OpenAI response
const getToolCalls = (response: any): any[] => {
  if (aiClient.isClaude) {
    return response.content?.filter((block: any) => block.type === 'tool_use') ?? [];
  }
  return response.choices?.[0]?.message?.tool_calls ?? [];
};

const AI_PROVIDER = (process.env.AI_PROVIDER || 'claude').toLowerCase();

const DEFAULT_COMPLETION_TIMEOUT_MS = AI_PROVIDER === 'ollama' ? 35000 : AI_PROVIDER === 'claude' ? 25000 : 18000;
const DEFAULT_COMPLETION_TOTAL_BUDGET_MS = AI_PROVIDER === 'ollama' ? 70000 : AI_PROVIDER === 'claude' ? 50000 : 30000;

const AI_COMPLETION_TIMEOUT_MS = Number(process.env.AI_COMPLETION_TIMEOUT_MS ?? DEFAULT_COMPLETION_TIMEOUT_MS);
const AI_COMPLETION_TOTAL_BUDGET_MS = Number(process.env.AI_COMPLETION_TOTAL_BUDGET_MS ?? DEFAULT_COMPLETION_TOTAL_BUDGET_MS);

const DEFAULT_CLAUDE_MODELS = [
  'claude-sonnet-4-20250514',
  'claude-sonnet-4-5',
  'claude-3-5-sonnet-20241022',
] as const;

const DEFAULT_GEMINI_MODELS = [
  'gemini-2.0-flash',
  'gemini-2.0-flash-lite',
  'gemini-1.5-flash',
  'gemini-1.5-pro',
] as const;

const DEFAULT_OPENROUTER_MODELS = [
  'qwen/qwen-2.5-7b-instruct:free',
  'meta-llama/llama-3.1-8b-instruct:free',
  'google/gemma-2-9b-it:free',
] as const;

const DEFAULT_OLLAMA_MODELS = [
  'llama3.2:1b',
  'phi3:mini',
  'llama3.2:3b',
] as const;

const getModelPool = (): string[] => {
  if (AI_PROVIDER === 'claude') {
    const configuredModel = process.env.CLAUDE_MODEL?.trim();
    if (!configuredModel) return [...DEFAULT_CLAUDE_MODELS];
    return [configuredModel, ...DEFAULT_CLAUDE_MODELS.filter((m) => m !== configuredModel)];
  }

  if (AI_PROVIDER === 'ollama') {
    const configuredModel = process.env.OLLAMA_MODEL?.trim();
    if (!configuredModel) return [...DEFAULT_OLLAMA_MODELS];
    return [configuredModel];
  }

  if (AI_PROVIDER === 'openrouter') {
    const configuredModel = process.env.OPENROUTER_MODEL?.trim();
    if (!configuredModel) return [...DEFAULT_OPENROUTER_MODELS];
    return [configuredModel, ...DEFAULT_OPENROUTER_MODELS.filter((m) => m !== configuredModel)];
  }

  const configuredModel = process.env.GEMINI_MODEL?.trim();
  if (!configuredModel) return [...DEFAULT_GEMINI_MODELS];
  return [configuredModel, ...DEFAULT_GEMINI_MODELS.filter((m) => m !== configuredModel)];
};

const createCompletion = async (params: {
  messages: ChatCompletionMessageParam[] | MessageParam[];
  tools?: ChatCompletionTool[];
  directchat: boolean;
  maxRetries?: number;
}) => {
  const { messages, tools, directchat, maxRetries = 2 } = params;
  let lastError: unknown;
  let quotaError: unknown;
  const modelPool = getModelPool();
  const startedAt = Date.now();
  const isClaude = aiClient.isClaude;

  const runWithTimeout = async <T>(operation: Promise<T>): Promise<T> => {
    let timeoutHandle: NodeJS.Timeout | undefined;
    try {
      return await Promise.race<T>([
        operation,
        new Promise<T>((_, reject) => {
          timeoutHandle = setTimeout(() => {
            reject(new Error('AI provider timeout'));
          }, AI_COMPLETION_TIMEOUT_MS);
        }),
      ]);
    } finally {
      if (timeoutHandle) clearTimeout(timeoutHandle);
    }
  };

  for (const model of modelPool) {
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      const elapsed = Date.now() - startedAt;
      if (elapsed >= AI_COMPLETION_TOTAL_BUDGET_MS) {
        throw new Error('AI response timeout. Please try again.');
      }

      try {
        if (isClaude) {
          // Claude API call
          const claudeMessages = (messages as MessageParam[]).filter(
            (m) => m.role === 'user' || m.role === 'assistant'
          );
          
          if (directchat || !tools || tools.length === 0) {
            return await runWithTimeout(
              aiClient.claude.messages.create({
                model,
                messages: claudeMessages,
                max_tokens: 1024,
              }) as unknown as Promise<any>
            );
          }

          // Claude tools format
          const claudeTools = tools?.map((tool: any) => ({
            name: tool.function?.name || '',
            description: tool.function?.description || '',
            input_schema: tool.function?.parameters || {},
          })) || [];

          return await runWithTimeout(
            aiClient.claude.messages.create({
              model,
              messages: claudeMessages,
              tools: claudeTools.length > 0 ? claudeTools : undefined,
              max_tokens: 1024,
            }) as unknown as Promise<any>
          );
        } else {
          // OpenAI/Gemini/Ollama/OpenRouter API call
          if (directchat || !tools || tools.length === 0) {
            return await runWithTimeout(
              aiClient.openai.chat.completions.create({
                model,
                messages: messages as ChatCompletionMessageParam[],
                max_tokens: 1000,
              })
            );
          }

          return await runWithTimeout(
            aiClient.openai.chat.completions.create({
              model,
              messages: messages as ChatCompletionMessageParam[],
              tools,
              tool_choice: 'auto',
              max_tokens: 1000,
            })
          );
        }
      } catch (error: any) {
        lastError = error;
        const status = (error as { status?: number })?.status;
        const isRateLimited = status === 429;
        const hasRetryLeft = attempt < maxRetries;

        // Log Claude-specific errors
        if (isClaude) {
          console.error(`[Claude API Error - Attempt ${attempt + 1}/${maxRetries + 1}]:`, {
            status: error?.status,
            message: error?.message,
            error: error?.error?.message || error?.error?.type,
          });
        }

        if (isRateLimited) quotaError = error;

        if (isRateLimited && hasRetryLeft) {
          await sleep(600 * 2 ** attempt);
          continue;
        }

        if (!isRateLimited) {
          break;
        }
      }
    }
  }

  const finalError = quotaError ?? lastError;
  
  if (isClaude) {
    console.error('[Claude API] All retries failed. Final error:', {
      message: finalError instanceof Error ? finalError.message : String(finalError),
      status: (finalError as any)?.status,
      type: (finalError as any)?.error?.type,
    });
  }
  
  throw finalError instanceof Error ? finalError : new Error('AI request failed');
};

const ensureTaskListId = async (userid: string, listid?: string): Promise<string> => {
  if (listid) return listid;
  const lists = await GetTaskList(userid);
  if (lists.length > 0) return lists[0]!.listid;
  const created = await CreateTaskList({ userid, name: 'General' });
  return created.listid;
};

const parseEndDate = (content: string): Date | null => {
  const normalized = content.toLowerCase().replace(/(st|nd|rd|th)/g, '');
  const monthDateYear = normalized.match(/\b(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{1,2}),?\s+(\d{4})\b/i);
  if (monthDateYear) {
    const parsed = new Date(`${monthDateYear[1]} ${monthDateYear[2]} ${monthDateYear[3]}`);
    if (!Number.isNaN(parsed.getTime())) return parsed;
  }

  const dayOfMonthYear = normalized.match(/\b(\d{1,2})\s+of\s+(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{4})\b/i);
  if (dayOfMonthYear) {
    const parsed = new Date(`${dayOfMonthYear[2]} ${dayOfMonthYear[1]} ${dayOfMonthYear[3]}`);
    if (!Number.isNaN(parsed.getTime())) return parsed;
  }

  return null;
};

const buildProviderFallbackReply = (content: string, language: string, error?: Error): string => {
  const text = content.toLowerCase();
  const isOllama = AI_PROVIDER === 'ollama';
  const isClaude = AI_PROVIDER === 'claude';

  // Log error for debugging
  if (error) {
    console.error(`[AI Error - ${AI_PROVIDER}]`, error.message);
  }

  if (text.includes('study plan') || text.includes('schedule')) {
    if (isClaude) {
      return language === 'French'
        ? 'Claude API est temporairement indisponible. Plan rapide: 1) 25 min revision active, 2) 5 min pause, 3) 25 min exercices, 4) 10 min recap. Reessayez dans quelques secondes.'
        : 'Claude API is temporarily unavailable. Quick plan: 1) 25 min active review, 2) 5 min break, 3) 25 min practice, 4) 10 min recap. Retry in a few seconds.';
    }
    return language === 'French'
      ? 'Le modele IA local est temporairement occupe. Plan rapide: 1) 25 min revision active, 2) 5 min pause, 3) 25 min exercices, 4) 10 min recap. Reessayez dans quelques secondes.'
      : 'The local AI model is temporarily busy. Quick plan: 1) 25 min active review, 2) 5 min break, 3) 25 min practice, 4) 10 min recap. Retry in a few seconds.';
  }

  if (text.includes('quiz')) {
    if (isClaude) {
      return language === 'French'
        ? 'Claude API est temporairement indisponible. Mini quiz: 1) Complexite de la recherche binaire? 2) Difference pile vs file? 3) Quand utiliser une table de hachage?'
        : 'Claude API is temporarily unavailable. Mini quiz: 1) Binary search complexity? 2) Stack vs queue? 3) When do you use a hash map?';
    }
    return language === 'French'
      ? 'Le modele IA est temporairement occupe. Mini quiz: 1) Complexite de la recherche binaire? 2) Difference pile vs file? 3) Quand utiliser une table de hachage?'
      : 'The AI model is temporarily busy. Mini quiz: 1) Binary search complexity? 2) Stack vs queue? 3) When do you use a hash map?';
  }

  if (isOllama) {
    return language === 'French'
      ? 'Le modele IA local est temporairement occupe. Reessayez dans 10-20 secondes.'
      : 'The local AI model is temporarily busy. Please retry in 10-20 seconds.';
  }

  if (isClaude) {
    return language === 'French'
      ? 'Le service Claude API est actuellement indisponible. Veuillez verifier votre cle API et reessayer dans quelques instants.'
      : 'Claude API service is currently unavailable. Please check your API key and try again in a few moments.';
  }

  return language === 'French'
    ? 'Le fournisseur IA est actuellement indisponible. Reessayez dans 1-2 minutes.'
    : 'The AI provider is currently unavailable. Retry in 1-2 minutes.';
};

const extractStatusFromContent = (content: string): TaskStatus | null => {
  const text = content.toLowerCase();
  if (text.includes('completed') || text.includes('done') || text.includes('finished')) return TaskStatus.COMPLETED;
  if (text.includes('in progress') || text.includes('in-progress') || text.includes('ongoing')) return TaskStatus.IN_PROGRESS;
  if (text.includes('overdue') || text.includes('late')) return TaskStatus.OVERDUE;
  if (text.includes('pending') || text.includes('todo') || text.includes('to do')) return TaskStatus.PENDING;
  return null;
};

const extractRenamePair = (content: string, entity: 'task' | 'tasklist'): { from: string; to: string } | null => {
  if (entity === 'tasklist') {
    const pattern = /rename\s+(?:task\s*list|tasklist)\s+(.+?)\s+to\s+(.+?)(?:[.!?]|$)/i;
    const match = content.match(pattern);
    if (match?.[1] && match?.[2]) {
      return { from: match[1].trim(), to: match[2].trim() };
    }
    return null;
  }

  const pattern = /rename\s+task\s+(.+?)\s+to\s+(.+?)(?:[.!?]|$)/i;
  const match = content.match(pattern);
  if (match?.[1] && match?.[2]) {
    return { from: match[1].trim(), to: match[2].trim() };
  }
  return null;
};

const extractLearningTopic = (content: string, listName: string): string => {
  const learnMatch = content.match(/to\s+learn\s+(.+?)(?:\s+in\s+\d+\s+steps?|\s+from\s+today|\s+by\s+|,|$)/i);
  if (learnMatch?.[1]) return learnMatch[1].trim();

  const cleanedListName = listName
    .replace(/\b(task\s*list|tasklist|learning|plan)\b/gi, '')
    .replace(/\s+/g, ' ')
    .trim();

  return cleanedListName || 'the requested subject';
};

const titleCase = (value: string): string =>
  value
    .trim()
    .split(/\s+/)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');

const inferTopicFromPrompt = (content: string): string | null => {
  const patterns = [
    /about\s+how\s+to\s+(?:make|cook|build|learn)\s+(.+?)(?:\s+in\s+\d+\s+steps?|\.|,|$)/i,
    /how\s+to\s+(?:make|cook|build|learn)\s+(.+?)(?:\s+in\s+\d+\s+steps?|\.|,|$)/i,
    /about\s+(.+?)(?:\s+in\s+\d+\s+steps?|\.|,|$)/i,
    /to\s+(?:make|cook|build|learn)\s+(.+?)(?:\s+in\s+\d+\s+steps?|\s+from\s+today|\s+by\s+|\.|,|$)/i,
  ];

  for (const pattern of patterns) {
    const match = content.match(pattern);
    if (match?.[1]?.trim()) {
      return match[1].trim();
    }
  }

  return null;
};

type LearningStep = { title: string; description: string };

const buildLearningSteps = (topic: string, taskCount: number): LearningStep[] => {
  const normalizedTopic = topic.toLowerCase();

  const flutterTrack: LearningStep[] = [
    {
      title: 'Set up Flutter environment',
      description: 'Install Flutter SDK, configure Android Studio or VS Code, run flutter doctor, and create your first app skeleton.',
    },
    {
      title: 'Learn Dart foundations',
      description: 'Practice Dart syntax, null safety, functions, classes, async/await, and write small console exercises.',
    },
    {
      title: 'Master widgets and layout',
      description: 'Build UI screens with StatelessWidget and StatefulWidget, Row/Column/Flex, padding, themes, and responsive layouts.',
    },
    {
      title: 'State management and navigation',
      description: 'Implement app state with Provider or Riverpod basics, add named routes, and handle form validation and user flows.',
    },
    {
      title: 'Build and polish a mini project',
      description: 'Create a complete Flutter project (auth + CRUD + API), test key screens, and prepare a deploy-ready release build.',
    },
  ];

  const frontendTrack: LearningStep[] = [
    {
      title: 'HTML and semantic structure',
      description: 'Learn semantic HTML tags, forms, accessibility basics, and build clean page structure from scratch.',
    },
    {
      title: 'CSS fundamentals and responsive UI',
      description: 'Practice box model, Flexbox, Grid, and media queries to recreate responsive layouts.',
    },
    {
      title: 'JavaScript core skills',
      description: 'Cover variables, functions, arrays/objects, DOM events, and async fetch with practical mini exercises.',
    },
    {
      title: 'Component architecture',
      description: 'Build reusable UI components, organize project structure, and manage state with a simple pattern.',
    },
    {
      title: 'Ship a portfolio-grade app',
      description: 'Create and deploy a full frontend project with routing, API integration, error handling, and polished UX.',
    },
  ];

  const cookingTrack: LearningStep[] = [
    {
      title: `Understand ${topic} ingredients and tools`,
      description: `List the required ingredients, quantities, and kitchen tools needed to prepare ${topic} correctly.`,
    },
    {
      title: `Prepare the filling for ${topic}`,
      description: `Season and cook the filling base, then let it cool so it can be wrapped neatly without tearing pastry.`,
    },
    {
      title: `Wrap and shape ${topic}`,
      description: `Practice folding technique step by step so each bourak is sealed and consistent in size.`,
    },
    {
      title: `Cook ${topic} to golden crisp`,
      description: `Fry or bake at the right heat, monitor color and texture, and avoid overcooking the outer layer.`,
    },
    {
      title: `Serve and refine ${topic}`,
      description: `Taste, adjust seasoning, and document improvements for your next batch.`,
    },
  ];

  const genericTrack: LearningStep[] = [
    {
      title: `Foundations of ${topic}`,
      description: `Study core concepts and terminology for ${topic}, then summarize them in your own notes.`,
    },
    {
      title: `${topic} hands-on basics`,
      description: `Complete beginner exercises to apply the fundamentals of ${topic} in short focused sessions.`,
    },
    {
      title: `Intermediate ${topic} practice`,
      description: `Work on increasingly difficult tasks and identify recurring mistakes to fix quickly.`,
    },
    {
      title: `${topic} mini project`,
      description: `Build a practical mini project that combines the main skills you learned in ${topic}.`,
    },
    {
      title: `${topic} revision and delivery`,
      description: `Review weak areas, refine your project or notes, and prepare a final polished outcome.`,
    },
  ];

  const baseTrack = normalizedTopic.includes('flutter')
    ? flutterTrack
    : (normalizedTopic.includes('bourak') || normalizedTopic.includes('recipe') || normalizedTopic.includes('cook') || normalizedTopic.includes('cooking'))
      ? cookingTrack
    : (normalizedTopic.includes('frontend') || normalizedTopic.includes('front-end'))
      ? frontendTrack
      : genericTrack;

  const steps: LearningStep[] = [];
  for (let i = 0; i < taskCount; i++) {
    const template = baseTrack[i] ?? {
      title: `${topic} practical sprint ${i + 1}`,
      description: `Deepen your ${topic} skills with a focused implementation sprint and document key learnings.`,
    };

    steps.push({
      title: template.title,
      description: template.description,
    });
  }

  return steps;
};

const createSmartTaskPlanFromPrompt = async (userid: string, content: string) => {
  const text = content.toLowerCase();
  const asksForTaskList = /task\s*list|tasklist/.test(text);
  const asksForSteps = /\bstep\b|\bsteps\b/.test(text);
  const asksToCreate = /\bcreate\b|\bmake\b|\bbuild\b/.test(text);

  if (!(asksForTaskList && asksForSteps && asksToCreate)) return null;

  const countMatch = text.match(/(\d+)\s+steps?/);
  const taskCount = countMatch ? Math.max(1, Math.min(15, Number(countMatch[1]))) : 5;

  const explicitTitle = pickFirstString(
    content.match(/task\s*list\s+titled\s+(.+?)(?:\s+to\s+learn|\s+from\s+today|\s+from\s+|\s+by\s+|,|$)/i)?.[1],
    content.match(/task\s*list\s+(?:named|called)\s+(.+?)(?:\s+to\s+learn|\s+from\s+today|\s+from\s+|\s+by\s+|,|$)/i)?.[1],
  );
  const inferredTopic = inferTopicFromPrompt(content);
  const listName = explicitTitle || (inferredTopic ? `${titleCase(inferredTopic)} Plan` : 'AI Learning Plan');
  const learningTopic = inferredTopic || extractLearningTopic(content, listName);
  const plannedSteps = buildLearningSteps(learningTopic, taskCount);

  const endDate = parseEndDate(content) ?? (() => {
    const d = new Date();
    d.setDate(d.getDate() + 7);
    return d;
  })();

  const startDate = new Date();
  startDate.setHours(9, 0, 0, 0);

  const totalMs = Math.max(24 * 60 * 60 * 1000, endDate.getTime() - startDate.getTime());
  const stepMs = taskCount > 1 ? totalMs / (taskCount - 1) : totalMs;

  const list = await CreateTaskList({ userid, name: listName });

  const createdTasks = [];
  for (let i = 0; i < taskCount; i++) {
    const deadline = new Date(startDate.getTime() + i * stepMs);
    deadline.setHours(23, 59, 0, 0);
    const step = plannedSteps[i]!;

    const task = await CreateTask({
      userid,
      listid: list.listid,
      title: `Step ${i + 1}: ${step.title}`,
      description: step.description,
      deadline,
      priority: i + 1,
      category: TaskCategory.ACADEMIC,
    });

    createdTasks.push(task);
  }

  return {
    reply: `Perfect, I created **${listName}** with **${taskCount}** steps and spread them out until **${endDate.toDateString()}**.`,
    actions: ['create_task_list', 'create_task'],
    createdTasks,
  };
};

const fallbackAssistantAction = async (userid: string, content: string) => {
  const text = content.toLowerCase();
  const actions: string[] = [];

  if ((text.includes('list') || text.includes('show')) && (text.includes('task list') || text.includes('tasklist'))) {
    const lists = await GetTaskList(userid);
    actions.push('list_task_lists');
    if (lists.length === 0) {
      return {
        reply: "You don't have any task lists yet. Want me to create one for you?",
        actions,
      };
    }

    return {
      reply: `Here are your task lists:\n${lists.map((list) => `- ${list.name}`).join('\n')}`,
      actions,
    };
  }

  if ((text.includes('list') || text.includes('show')) && text.includes('task')) {
    const tasks = await GetTasks(userid);
    actions.push('list_tasks');
    if (tasks.length === 0) {
      return {
        reply: "You don't have any tasks yet. I can help you add one in a second.",
        actions,
      };
    }

    const preview = tasks
      .slice(0, 10)
      .map((task) => `- ${task.title} (${task.status})`)
      .join('\n');

    return {
      reply: `Here are your current tasks:\n${preview}`,
      actions,
    };
  }

  if ((text.includes('create') || text.includes('add')) && (text.includes('task list') || text.includes('tasklist'))) {
    const title = pickFirstString(
      content.match(/(?:task\s*list|tasklist)\s+(?:named|called|titled)\s+(.+?)(?:[.!?]|$)/i)?.[1],
      content.match(/(?:create|add)\s+(?:a\s+)?(?:task\s*list|tasklist)\s+(.+?)(?:[.!?]|$)/i)?.[1],
    ) ?? 'New Task List';

    const list = await CreateTaskList({ userid, name: title });
    actions.push('create_task_list');
    return {
      reply: `Done, I created **${list.name}** for you.`,
      actions,
    };
  }

  const renameList = extractRenamePair(content, 'tasklist');
  if (renameList || ((text.includes('update') || text.includes('rename') || text.includes('change')) && (text.includes('task list') || text.includes('tasklist')))) {
    const fromName = renameList?.from ?? extractEntityQueryFromContent(content, 'tasklist');
    const toName = renameList?.to ?? pickFirstString(
      content.match(/(?:to|as)\s+(.+?)(?:[.!?]|$)/i)?.[1],
      content.match(/name\s+(?:to|as)\s+(.+?)(?:[.!?]|$)/i)?.[1],
    );

    if (fromName && toName) {
      const listId = await resolveTaskListIdForUser(userid, fromName);
      if (!listId) {
        return { reply: `I couldn't find a task list named **${fromName}**.`, actions };
      }

      await UpdateTaskList(listId, { name: toName } as UpdateTaskListDTO);
      actions.push('update_task_list');
      return {
        reply: `Nice, I renamed **${fromName}** to **${toName}**.`,
        actions,
      };
    }
  }

  if ((text.includes('delete') || text.includes('remove')) && text.includes('task')) {
    const selector = extractEntityQueryFromContent(content, 'task') ?? pickFirstString(
      content.match(/(?:delete|remove)\s+task\s+(.+?)(?:[.!?]|$)/i)?.[1],
    );

    if (selector) {
      const taskId = await resolveTaskIdForUser(userid, selector);
      if (!taskId) {
        return { reply: `I couldn't find a task named **${selector}**.`, actions };
      }

      await DeleteTask(taskId);
      actions.push('delete_task');
      return {
        reply: `Done, I removed **${selector}**.`,
        actions,
      };
    }
  }

  const renameTask = extractRenamePair(content, 'task');
  if (renameTask) {
    const taskId = await resolveTaskIdForUser(userid, renameTask.from);
    if (!taskId) {
      return { reply: `I couldn't find a task named **${renameTask.from}**.`, actions };
    }

    await UpdateTask(taskId, { title: renameTask.to });
    actions.push('update_task');
    return {
      reply: `Great, I renamed **${renameTask.from}** to **${renameTask.to}**.`,
      actions,
    };
  }

  if ((text.includes('mark') || text.includes('set') || text.includes('update')) && text.includes('task')) {
    const status = extractStatusFromContent(content);
    const selector = extractEntityQueryFromContent(content, 'task');

    if (status && selector) {
      const taskId = await resolveTaskIdForUser(userid, selector);
      if (!taskId) {
        return { reply: `I couldn't find a task named **${selector}**.`, actions };
      }

      await UpdateTaskStatus(taskId, { status });
      actions.push('update_task_status');
      return {
        reply: `Done, I marked **${selector}** as **${status}**.`,
        actions,
      };
    }
  }

  if (text.includes('create') && text.includes('task')) {
    const titleMatch = content.match(/titled\s+(.+)$/i);
    const title = titleMatch?.[1]?.trim() || 'New task from AI request';

    const listid = await ensureTaskListId(userid);
    const createTaskData: CreateTaskDTO = {
      userid,
      listid,
      title,
    };

    if (text.includes('high priority')) createTaskData.priority = 3;
    else if (text.includes('medium priority')) createTaskData.priority = 2;
    else if (text.includes('low priority')) createTaskData.priority = 1;

    if (text.includes('academic')) createTaskData.category = TaskCategory.ACADEMIC;
    else if (text.includes('work')) createTaskData.category = TaskCategory.WORK;
    else if (text.includes('health')) createTaskData.category = TaskCategory.HEALTH;
    else if (text.includes('personal')) createTaskData.category = TaskCategory.PERSONAL;

    if (text.includes('tomorrow')) {
      const d = new Date();
      d.setDate(d.getDate() + 1);
      d.setHours(23, 59, 0, 0);
      createTaskData.deadline = d;
    }

    const task = await CreateTask(createTaskData);
    actions.push('create_task');
    return {
      reply: `Done, I added **${task.title}**.`,
      actions,
    };
  }

  if (text.includes('schedule') && text.includes('focus session')) {
    const durationMatch = text.match(/(\d+)\s*minute/);
    const duration = durationMatch ? Math.max(1, Number(durationMatch[1])) : 50;
    const start = new Date();
    const end = new Date(start.getTime() + duration * 60_000);

    const session = await CreateSession({
      userid,
      starttime: start,
      endtime: end,
      allowbreakminutes: 0,
    });

    const tasks = await GetTasks(userid);
    const pending = tasks
      .filter((t) => t.status === TaskStatus.PENDING || t.status === TaskStatus.IN_PROGRESS)
      .sort((a, b) => (b.priority - a.priority) || ((a.deadline?.getTime() ?? Number.MAX_SAFE_INTEGER) - (b.deadline?.getTime() ?? Number.MAX_SAFE_INTEGER)));

    if (pending.length > 0) {
      await prisma.sessiontask.create({
        data: { taskid: pending[0]!.taskid, sessionid: session.sessionid },
      });
    }

    actions.push('create_focus_session');
    return {
      reply: `You're all set. I scheduled a **${duration}-minute** focus session starting now.`,
      actions,
    };
  }

  return {
    reply: 'I can help you manage tasks and focus sessions. Tell me what you want to add, update, or remove.',
    actions,
  };
};


export const SendMessage = async (data: SendMessageDTO) => {
  if (!data.content?.trim()) throw new Error('Message content is required');
  if (!data.userid) throw new Error('User ID is required');

  const assistant = await AssistantRepository.findOrCreate(data.userid, data.major);

  const memory = await StudentMemoryRepository.findByUser(data.userid);
  if (data.major) { await StudentMemoryRepository.upsert(data.userid, 'major', data.major); memory['major'] = data.major; }
  if (data.university) { await StudentMemoryRepository.upsert(data.userid, 'university', data.university); memory['university'] = data.university; }
  if (data.year) { await StudentMemoryRepository.upsert(data.userid, 'year', data.year); memory['year'] = data.year; }

  let ragContext = '';
  try {
    const queryEmbedding = await getEmbedding(data.content);
    const chunks = await searchSimilarChunks(queryEmbedding, data.userid, 4);
    const goodChunks = chunks.filter(c => c.similarity > 0.7);
    if (goodChunks.length > 0) {
      ragContext = goodChunks.map((c, i) => `[Source ${i + 1}]\n${c.content}`).join('\n\n');
    }
  } catch {
  }

  const historyLimit = AI_PROVIDER === 'ollama' ? 4 : 10;
  const history = await ChatHistoryRepository.findByUser(data.userid, historyLimit);
  const historyMessages = history.reverse().map(h => ({
    role: h.role === 'USER' ? 'user' as const : 'assistant' as const,
    content: h.content,
  }));

  const language = detectLanguage(data.content);

  const systemPrompt = buildSystemPrompt(memory, ragContext, language, data.faithmode ?? false);

  const tools: ChatCompletionTool[] = [
    {
      type: 'function',
      function: {
        name: 'create_task',
        description: 'Create a new task for the current user.',
        parameters: {
          type: 'object',
          properties: {
            title: { type: 'string' },
            description: { type: 'string' },
            listid: { type: 'string' },
            deadline: { type: 'string', description: 'ISO datetime' },
            priority: { type: 'integer' },
            category: { type: 'string', enum: ['ACADEMIC', 'PERSONAL', 'WORK', 'HEALTH', 'OTHER'] },
          },
          required: ['title'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'update_task',
        description: 'Update task details (title, description, deadline, priority, category). Prefer taskQuery when user gives a task name instead of taskid.',
        parameters: {
          type: 'object',
          properties: {
            taskid: { type: 'string' },
            taskQuery: { type: 'string', description: 'Task name/title from user message when taskid is not provided.' },
            currentTitle: { type: 'string' },
            title: { type: 'string' },
            description: { type: 'string' },
            deadline: { type: 'string', description: 'ISO datetime' },
            priority: { type: 'integer' },
            category: { type: 'string', enum: ['ACADEMIC', 'PERSONAL', 'WORK', 'HEALTH', 'OTHER'] },
          },
          required: [],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'update_task_status',
        description: 'Update task status. Prefer taskQuery when user gives a task name instead of taskid.',
        parameters: {
          type: 'object',
          properties: {
            taskid: { type: 'string' },
            taskQuery: { type: 'string', description: 'Task name/title from user message when taskid is not provided.' },
            currentTitle: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'OVERDUE'] },
          },
          required: ['status'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'delete_task',
        description: 'Delete a task. Prefer taskQuery when user gives a task name instead of taskid.',
        parameters: {
          type: 'object',
          properties: {
            taskid: { type: 'string' },
            taskQuery: { type: 'string', description: 'Task name/title from user message when taskid is not provided.' },
            currentTitle: { type: 'string' },
          },
          required: [],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'list_tasks',
        description: 'List tasks for the current user.',
        parameters: { type: 'object', properties: {} },
      },
    },
    {
      type: 'function',
      function: {
        name: 'create_task_list',
        description: 'Create a new task list.',
        parameters: {
          type: 'object',
          properties: { name: { type: 'string' } },
          required: ['name'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'list_task_lists',
        description: 'List task lists for the current user.',
        parameters: { type: 'object', properties: {} },
      },
    },
    {
      type: 'function',
      function: {
        name: 'update_task_list',
        description: 'Update a task list name. Prefer listQuery when user gives a task list name instead of listid.',
        parameters: {
          type: 'object',
          properties: {
            listid: { type: 'string' },
            listQuery: { type: 'string', description: 'Task list name from user message when listid is not provided.' },
            currentName: { type: 'string' },
            name: { type: 'string' },
          },
          required: ['name'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'create_focus_session',
        description: 'Create a focus session; optionally link it to a task.',
        parameters: {
          type: 'object',
          properties: {
            durationMinutes: { type: 'integer' },
            startTime: { type: 'string', description: 'ISO datetime; defaults to now' },
            allowBreakMinutes: { type: 'integer' },
            taskid: { type: 'string' },
          },
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'start_focus_session',
        description: 'Start an existing focus session now.',
        parameters: {
          type: 'object',
          properties: { sessionid: { type: 'string' } },
          required: ['sessionid'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'end_focus_session',
        description: 'End an existing active focus session now.',
        parameters: {
          type: 'object',
          properties: { sessionid: { type: 'string' } },
          required: ['sessionid'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'list_focus_sessions',
        description: 'List focus sessions for the current user.',
        parameters: { type: 'object', properties: {} },
      },
    },
  ];

  const updateIntent = isUpdateIntent(data.content);
  const allowedTools = updateIntent
    ? tools.filter((tool) => tool.type === 'function' && UPDATE_ONLY_TOOL_NAMES.has(tool.function.name))
    : tools;

  const messages: ChatCompletionMessageParam[] = [
    { role: 'system', content: systemPrompt },
    ...historyMessages,
    { role: 'user', content: data.content },
  ];

  if (data.directchat && !updateIntent) {
    const smartPlan = await createSmartTaskPlanFromPrompt(data.userid, data.content);
    if (smartPlan) {
      await ChatHistoryRepository.save(data.userid, 'USER', data.content);
      await ChatHistoryRepository.save(data.userid, 'ASSISTANT', smartPlan.reply);
      ExtractAndSaveMemory(data.userid, data.content, memory).catch(() => {});

      return {
        reply: smartPlan.reply,
        language,
        usedDocuments: ragContext.length > 0,
        actions: smartPlan.actions,
      };
    }

    let aiReply = "Sorry, I couldn't generate a response right now.";
    try {
      const response = await createCompletion({
        messages,
        directchat: true,
      });
      const getResponseContent = (resp: any): string | null => {
        if (aiClient.isClaude) {
          const textBlock = (resp.content as any[])?.[0];
          return textBlock?.type === 'text' ? textBlock.text : null;
        }
        return resp.choices?.[0]?.message?.content ?? null;
      };
      const content = getResponseContent(response);
      aiReply = content ?? aiReply;
    } catch (error1: any) {
      try {
        // Compact retry path for local models: minimal context reduces intermittent Ollama failures.
        const compactRetry = await createCompletion({
          messages: [
            {
              role: 'system',
              content: 'You are Neurova, a concise and helpful academic assistant. Respond clearly in markdown.',
            },
            { role: 'user', content: data.content },
          ],
          directchat: true,
          maxRetries: 0,
        });
        const compactText = getResponseText(compactRetry);
        aiReply = compactText?.trim() || buildProviderFallbackReply(data.content, language, error1);
      } catch (error2: any) {
        aiReply = buildProviderFallbackReply(data.content, language, error2);
      }
    }

    await ChatHistoryRepository.save(data.userid, 'USER', data.content);
    await ChatHistoryRepository.save(data.userid, 'ASSISTANT', aiReply);
    ExtractAndSaveMemory(data.userid, data.content, memory).catch(() => {});

    return {
      reply: aiReply,
      language,
      usedDocuments: ragContext.length > 0,
      actions: [],
    };
  }

  let aiReply = "Sorry, I couldn't put together a response just yet.";
  let actions: string[] = [];
  let lastError: any = null;

  try {
    const response = await createCompletion({
      messages,
      tools: allowedTools,
      directchat: Boolean(data.directchat),
    });

    const assistantContent = getResponseText(response) ?? '';
    aiReply = assistantContent;
    const toolCalls = getToolCalls(response);
    const inlineToolCalls = toolCalls.length === 0 ? parseInlineToolCalls(aiReply) : [];
    const toolCallsToExecute = toolCalls.length > 0 ? toolCalls : inlineToolCalls;

    if (toolCallsToExecute.length > 0) {
      // Add assistant message to conversation
      messages.push({
        role: 'assistant',
        content: aiReply,
      } as ChatCompletionMessageParam);

      for (const toolCall of toolCallsToExecute) {
        if (toolCall.type !== 'function') continue;
        if (updateIntent && !UPDATE_ONLY_TOOL_NAMES.has(toolCall.function.name)) {
          messages.push({
            role: 'tool',
            tool_call_id: toolCall.id,
            content: JSON.stringify({ error: `Tool ${toolCall.function.name} is not allowed for update requests` }),
          });
          continue;
        }

        const args = parseToolArguments(toolCall.function.arguments ?? '{}');

        try {
          let result: unknown;

        switch (toolCall.function.name) {
          case 'create_task': {
            const resolvedListId = await ensureTaskListId(
              data.userid,
              typeof args.listid === 'string' ? args.listid : undefined,
            );

            const createTaskData: CreateTaskDTO = {
              userid: data.userid,
              listid: resolvedListId,
              title: String(args.title ?? ''),
            };

            if (typeof args.description === 'string') createTaskData.description = args.description;
            if (typeof args.deadline === 'string') createTaskData.deadline = new Date(args.deadline);
            if (typeof args.priority === 'number') createTaskData.priority = args.priority;
            const taskCategory = toTaskCategory(args.category);
            if (taskCategory) createTaskData.category = taskCategory;

            result = await CreateTask(createTaskData);
            actions.push('create_task');
            break;
          }
          case 'update_task': {
            const selector = pickFirstString(
              args.taskQuery,
              args.currentTitle,
              args.taskTitle,
              args.task_name,
              args.name,
              extractEntityQueryFromContent(data.content, 'task'),
            );

            const matchedTaskId = selector
              ? await resolveTaskIdForUser(data.userid, selector) ?? undefined
              : undefined;

            let resolvedTaskId = matchedTaskId ?? (typeof args.taskid === 'string' ? args.taskid : undefined);
            if (!resolvedTaskId && selector) {
              resolvedTaskId = await resolveTaskIdForUser(data.userid, selector) ?? undefined;
            }

            if (!resolvedTaskId) throw new Error('taskid or taskQuery is required');
            const updateTaskData: UpdateTaskDTO = {};
            if (typeof args.title === 'string') updateTaskData.title = args.title;
            if (typeof args.description === 'string') updateTaskData.description = args.description;
            if (typeof args.deadline === 'string') updateTaskData.deadline = new Date(args.deadline);
            if (typeof args.priority === 'number') updateTaskData.priority = args.priority;
            const taskCategory = toTaskCategory(args.category);
            if (taskCategory) updateTaskData.category = taskCategory;

            result = await UpdateTask(resolvedTaskId, updateTaskData);
            actions.push('update_task');
            break;
          }
          case 'update_task_status': {
            const selector = pickFirstString(
              args.taskQuery,
              args.currentTitle,
              args.taskTitle,
              args.task_name,
              args.name,
              extractEntityQueryFromContent(data.content, 'task'),
            );

            const matchedTaskId = selector
              ? await resolveTaskIdForUser(data.userid, selector) ?? undefined
              : undefined;

            let resolvedTaskId = matchedTaskId ?? (typeof args.taskid === 'string' ? args.taskid : undefined);
            if (!resolvedTaskId && selector) {
              resolvedTaskId = await resolveTaskIdForUser(data.userid, selector) ?? undefined;
            }

            if (!resolvedTaskId) throw new Error('taskid or taskQuery is required');
            const status = toTaskStatus(args.status);
            if (!status) throw new Error('valid status is required');
            result = await UpdateTaskStatus(resolvedTaskId, { status });
            actions.push('update_task_status');
            break;
          }
          case 'delete_task': {
            const selector = pickFirstString(
              args.taskQuery,
              args.currentTitle,
              args.taskTitle,
              args.task_name,
              args.name,
              extractEntityQueryFromContent(data.content, 'task'),
            );

            const matchedTaskId = selector
              ? await resolveTaskIdForUser(data.userid, selector) ?? undefined
              : undefined;

            const resolvedTaskId = matchedTaskId ?? (typeof args.taskid === 'string' ? args.taskid : undefined);
            if (!resolvedTaskId) throw new Error('taskid or taskQuery is required');
            result = await DeleteTask(resolvedTaskId);
            actions.push('delete_task');
            break;
          }
          case 'list_tasks': {
            result = await GetTasks(data.userid);
            actions.push('list_tasks');
            break;
          }
          case 'create_task_list': {
            if (typeof args.name !== 'string' || !args.name.trim()) throw new Error('name is required');
            result = await CreateTaskList({ userid: data.userid, name: args.name.trim() });
            actions.push('create_task_list');
            break;
          }
          case 'list_task_lists': {
            result = await GetTaskList(data.userid);
            actions.push('list_task_lists');
            break;
          }
          case 'update_task_list': {
            const selector = pickFirstString(
              args.listQuery,
              args.currentName,
              args.listName,
              args.tasklist,
              extractEntityQueryFromContent(data.content, 'tasklist'),
            );

            const matchedListId = selector
              ? await resolveTaskListIdForUser(data.userid, selector) ?? undefined
              : undefined;

            let resolvedListId = matchedListId ?? (typeof args.listid === 'string' ? args.listid : undefined);
            if (!resolvedListId && selector) {
              resolvedListId = await resolveTaskListIdForUser(data.userid, selector) ?? undefined;
            }

            if (!resolvedListId) throw new Error('listid or listQuery is required');
            if (typeof args.name !== 'string' || !args.name.trim()) throw new Error('name is required');

            const updateTaskListData: UpdateTaskListDTO = {
              name: args.name.trim(),
            };

            result = await UpdateTaskList(resolvedListId, updateTaskListData);
            actions.push('update_task_list');
            break;
          }
          case 'create_focus_session': {
            const start = typeof args.startTime === 'string' ? new Date(args.startTime) : new Date();
            const duration = typeof args.durationMinutes === 'number' ? Math.max(1, args.durationMinutes) : 50;
            const session = await CreateSession({
              userid: data.userid,
              starttime: start,
              endtime: new Date(start.getTime() + duration * 60_000),
              allowbreakminutes: typeof args.allowBreakMinutes === 'number' ? Math.max(0, args.allowBreakMinutes) : 0,
            });

            if (typeof args.taskid === 'string' && args.taskid) {
              await prisma.sessiontask.create({
                data: { taskid: args.taskid, sessionid: session.sessionid },
              });
            }

            result = session;
            actions.push('create_focus_session');
            break;
          }
          case 'start_focus_session': {
            if (typeof args.sessionid !== 'string') throw new Error('sessionid is required');
            result = await StartSession(args.sessionid);
            actions.push('start_focus_session');
            break;
          }
          case 'end_focus_session': {
            if (typeof args.sessionid !== 'string') throw new Error('sessionid is required');
            result = await EndSession(args.sessionid);
            actions.push('end_focus_session');
            break;
          }
          case 'list_focus_sessions': {
            result = await GetSessions(data.userid);
            actions.push('list_focus_sessions');
            break;
          }
          default:
            result = { message: `Unsupported tool: ${toolCall.function.name}` };
        }

          messages.push({
            role: 'tool',
            tool_call_id: toolCall.id,
            content: JSON.stringify(result),
          });
        } catch (error) {
          messages.push({
            role: 'tool',
            tool_call_id: toolCall.id,
            content: JSON.stringify({
              error: error instanceof Error ? error.message : 'Tool execution failed',
            }),
          });
        }
      }

      const followUp = await createCompletion({
        messages,
        directchat: true,
      });

      const followUpText = getResponseText(followUp);
      aiReply = followUpText ?? aiReply;
    }

    if (isActionIntent(data.content)) {
      const updateActions = new Set(['update_task', 'update_task_status', 'update_task_list', 'delete_task']);
      const hasUpdateMutation = actions.some((action) => updateActions.has(action));
      const shouldFallback = updateIntent ? !hasUpdateMutation : actions.length === 0;

      if (shouldFallback) {
        const fallback = await fallbackAssistantAction(data.userid, data.content);
        aiReply = fallback.reply;
        actions = fallback.actions;
      }
    }
  } catch (error: any) {
    lastError = error;
    console.error('[SendMessage] AI Completion Error:', error.message);
    
    if (isActionIntent(data.content)) {
      const fallback = await fallbackAssistantAction(data.userid, data.content);
      aiReply = fallback.reply;
      actions = fallback.actions;
    } else {
      aiReply = buildProviderFallbackReply(data.content, language, error);
      actions = [];
    }
  }

  await ChatHistoryRepository.save(data.userid, 'USER', data.content);
  await ChatHistoryRepository.save(data.userid, 'ASSISTANT', aiReply);

  ExtractAndSaveMemory(data.userid, data.content, memory).catch(() => {});

  return {
    reply: aiReply,
    language,
    usedDocuments: ragContext.length > 0,
    actions,
  };
};
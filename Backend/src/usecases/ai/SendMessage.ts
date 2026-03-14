import openai from '../../infrastructure/ai/openai.client.js';
import type { ChatCompletionMessageParam, ChatCompletionTool } from 'openai/resources/chat/completions';
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
import { CreateSession } from '../sessions/CreateSession.js';
import { StartSession } from '../sessions/StartSession.js';
import { EndSession } from '../sessions/EndSession.js';
import { GetSessions } from '../sessions/GetSession.js';
import { TaskCategory, TaskStatus } from '../../entities/Task.js';
import type { CreateTaskDTO, UpdateTaskDTO } from '../../interfaces/dtos/Task.dto.js';
import { ExtractAndSaveMemory } from './Extractandsavememory.js';

// Utility helpers

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
Personality: encouraging, focused, knowledgeable, concise.
Help with: concept explanations, study strategies, problem solving, exam prep, and academic planning.
Always format responses clearly using markdown (bold, bullet points, code blocks when relevant).

You can perform actions through tools for:
- Task management: create/update/delete/list tasks, update task status
- Task lists: create/list
- Focus sessions: create/list/start/end

When a user asks for an action, call the appropriate tool first, then summarize the result clearly.${profileBlock}${ragBlock}${faithBlock}${langBlock}`;
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

const ensureTaskListId = async (userid: string, listid?: string): Promise<string> => {
  if (listid) return listid;
  const lists = await GetTaskList(userid);
  if (lists.length > 0) return lists[0]!.listid;
  const created = await CreateTaskList({ userid, name: 'General' });
  return created.listid;
};

const fallbackAssistantAction = async (userid: string, content: string) => {
  const text = content.toLowerCase();
  const actions: string[] = [];

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
      reply: `Task created: **${task.title}**.`,
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
      await prisma.task_focussession.create({
        data: { taskid: pending[0]!.taskid, sessionid: session.sessionid },
      });
    }

    actions.push('create_focus_session');
    return {
      reply: `Focus session scheduled for **${duration} minutes** starting now.`,
      actions,
    };
  }

  return {
    reply: 'I can help with tasks and focus sessions. Ask me to create a task or schedule a focus session.',
    actions,
  };
};

// Main flow

export const SendMessage = async (data: SendMessageDTO) => {
  if (!data.content?.trim()) throw new Error('Message content is required');
  if (!data.userid) throw new Error('User ID is required');

  // Ensure the user has an assistant profile.
  const assistant = await AssistantRepository.findOrCreate(data.userid, data.major);

  // Load memory and refresh fields provided in this request.
  const memory = await StudentMemoryRepository.findByUser(data.userid);
  if (data.major) { await StudentMemoryRepository.upsert(data.userid, 'major', data.major); memory['major'] = data.major; }
  if (data.university) { await StudentMemoryRepository.upsert(data.userid, 'university', data.university); memory['university'] = data.university; }
  if (data.year) { await StudentMemoryRepository.upsert(data.userid, 'year', data.year); memory['year'] = data.year; }

  // Try to pull useful context from indexed documents.
  let ragContext = '';
  try {
    const queryEmbedding = await getEmbedding(data.content);
    const chunks = await searchSimilarChunks(queryEmbedding, data.userid, 4);
    const goodChunks = chunks.filter(c => c.similarity > 0.7);
    if (goodChunks.length > 0) {
      ragContext = goodChunks.map((c, i) => `[Source ${i + 1}]\n${c.content}`).join('\n\n');
    }
  } catch {
    // Continue without RAG context if retrieval fails.
  }

  // Use recent conversation context.
  const history = await ChatHistoryRepository.findByUser(data.userid, 10);
  const historyMessages = history.reverse().map(h => ({
    role: h.role === 'USER' ? 'user' as const : 'assistant' as const,
    content: h.content,
  }));

  // Match the user's language where possible.
  const language = detectLanguage(data.content);

  // Build prompt and ask the model.
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
        description: 'Update task details (title, description, deadline, priority, category).',
        parameters: {
          type: 'object',
          properties: {
            taskid: { type: 'string' },
            title: { type: 'string' },
            description: { type: 'string' },
            deadline: { type: 'string', description: 'ISO datetime' },
            priority: { type: 'integer' },
            category: { type: 'string', enum: ['ACADEMIC', 'PERSONAL', 'WORK', 'HEALTH', 'OTHER'] },
          },
          required: ['taskid'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'update_task_status',
        description: 'Update task status.',
        parameters: {
          type: 'object',
          properties: {
            taskid: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'OVERDUE'] },
          },
          required: ['taskid', 'status'],
        },
      },
    },
    {
      type: 'function',
      function: {
        name: 'delete_task',
        description: 'Delete a task by id.',
        parameters: {
          type: 'object',
          properties: { taskid: { type: 'string' } },
          required: ['taskid'],
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

  const messages: ChatCompletionMessageParam[] = [
    { role: 'system', content: systemPrompt },
    ...historyMessages,
    { role: 'user', content: data.content },
  ];

  let aiReply = 'Sorry, I could not generate a response.';
  let actions: string[] = [];

  try {
    const response = await openai.chat.completions.create({
      model: 'gemini-2.0-flash',
      messages,
      tools,
      tool_choice: 'auto',
      max_tokens: 1000,
    });

    const assistantMessage = response.choices[0]?.message;
    aiReply = assistantMessage?.content ?? aiReply;

    if (assistantMessage?.tool_calls && assistantMessage.tool_calls.length > 0) {
      messages.push(assistantMessage as ChatCompletionMessageParam);

      for (const toolCall of assistantMessage.tool_calls) {
        if (toolCall.type !== 'function') continue;
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
            if (typeof args.taskid !== 'string') throw new Error('taskid is required');
            const updateTaskData: UpdateTaskDTO = {};
            if (typeof args.title === 'string') updateTaskData.title = args.title;
            if (typeof args.description === 'string') updateTaskData.description = args.description;
            if (typeof args.deadline === 'string') updateTaskData.deadline = new Date(args.deadline);
            if (typeof args.priority === 'number') updateTaskData.priority = args.priority;
            const taskCategory = toTaskCategory(args.category);
            if (taskCategory) updateTaskData.category = taskCategory;

            result = await UpdateTask(args.taskid, updateTaskData);
            actions.push('update_task');
            break;
          }
          case 'update_task_status': {
            if (typeof args.taskid !== 'string') throw new Error('taskid is required');
            const status = toTaskStatus(args.status);
            if (!status) throw new Error('valid status is required');
            result = await UpdateTaskStatus(args.taskid, { status });
            actions.push('update_task_status');
            break;
          }
          case 'delete_task': {
            if (typeof args.taskid !== 'string') throw new Error('taskid is required');
            result = await DeleteTask(args.taskid);
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
              await prisma.task_focussession.create({
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

      const followUp = await openai.chat.completions.create({
        model: 'gemini-2.0-flash',
        messages,
        max_tokens: 1000,
      });

      aiReply = followUp.choices[0]?.message?.content ?? aiReply;
    }
  } catch {
    const fallback = await fallbackAssistantAction(data.userid, data.content);
    aiReply = fallback.reply;
    actions = fallback.actions;
  }

  // Persist both user and assistant messages.
  await ChatHistoryRepository.save(data.userid, 'USER', data.content);
  await ChatHistoryRepository.save(data.userid, 'ASSISTANT', aiReply);

  // Update long-term memory in the background.
  ExtractAndSaveMemory(data.userid, data.content, memory).catch(() => {});

  return {
    reply: aiReply,
    language,
    usedDocuments: ragContext.length > 0,
    actions,
  };
};
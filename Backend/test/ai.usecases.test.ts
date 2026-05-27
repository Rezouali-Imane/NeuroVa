import { beforeEach, describe, expect, it, vi } from 'vitest';
import openai from '../src/infrastructure/ai/openai.client.js';
import prisma from '../src/infrastructure/database/prisma.client.js';
import { HmacClient } from '../src/infrastructure/hmac.client.js';
import { getPrayerTimes } from '../src/infrastructure/external/prayertime.client.js';
import * as pdfChunker from '../src/infrastructure/pdf.chunker.js';
import * as embeddingClient from '../src/infrastructure/embedding.client.js';
import * as vectorClient from '../src/infrastructure/supabase.vector.client.js';
import { ChatHistoryRepository, StudentMemoryRepository, KnowledgeBaseRepository, AssistantRepository } from '../src/interfaces/repositories/AIRepositories.js';
import { FocusSessionRepository } from '../src/interfaces/repositories/FocusSessionRepository.js';
import { GetChatHistory } from '../src/usecases/ai/GetChatHistory.js';
import { ClearChatHistory } from '../src/usecases/ai/ClearChatHistory.js';
import { GetStudentMemory } from '../src/usecases/ai/Getstudentmemory.js';
import { UpdateStudentMemory } from '../src/usecases/ai/Updatestudentmemory.js';
import { GetKnowledgeBase, DeleteDocument } from '../src/usecases/ai/Knowledgebase.usecases.js';
import { GenerateStudyPlan } from '../src/usecases/ai/GenerateStudyPlan.js';
import { AnalyzeWeakness } from '../src/usecases/ai/Analyzeweakness.js';
import { ScheduleFocusSession } from '../src/usecases/ai/Schedulefocussession.js';
import { ProcessDocument } from '../src/usecases/ai/Processdocument.js';
import { SendTaskReminders } from '../src/usecases/ai/Sendtaskreminders.js';

describe('ai usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('chat history and memory usecases validate and shape results', async () => {
    await expect(GetChatHistory('')).rejects.toThrow('User ID is required');
    vi.spyOn(ChatHistoryRepository, 'findByUser').mockResolvedValue([{ chatid: '2' }, { chatid: '1' }] as any);
    await expect(GetChatHistory('usr1')).resolves.toEqual([{ chatid: '1' }, { chatid: '2' }]);

    await expect(ClearChatHistory('')).rejects.toThrow('User ID is required');
    vi.spyOn(ChatHistoryRepository, 'clearByUser').mockResolvedValue({ count: 2 } as any);
    await expect(ClearChatHistory('usr1')).resolves.toEqual({ message: 'Chat history cleared successfully' });

    await expect(GetStudentMemory('')).rejects.toThrow('User ID is required');
    vi.spyOn(StudentMemoryRepository, 'findByUser').mockResolvedValue({ major: 'CS' });
    await expect(GetStudentMemory('usr1')).resolves.toEqual({ memory: { major: 'CS' } });

    await expect(UpdateStudentMemory({ userid: '', key: 'major', value: 'CS' })).rejects.toThrow('User ID is required');
    await expect(UpdateStudentMemory({ userid: 'usr1', key: '', value: 'CS' })).rejects.toThrow('Memory key is required');
    await expect(UpdateStudentMemory({ userid: 'usr1', key: 'major', value: '' })).rejects.toThrow('Memory value is required');
    vi.spyOn(StudentMemoryRepository, 'upsert').mockResolvedValue({} as any);
    await expect(UpdateStudentMemory({ userid: 'usr1', key: 'major', value: 'CS' })).resolves.toEqual({ message: 'Memory updated', key: 'major', value: 'CS' });
  });

  it('knowledge base usecases validate and use repositories', async () => {
    await expect(GetKnowledgeBase('')).rejects.toThrow('User ID is required');
    vi.spyOn(AssistantRepository, 'findByUser').mockResolvedValue(null as any);
    await expect(GetKnowledgeBase('usr1')).resolves.toEqual([]);

    vi.spyOn(AssistantRepository, 'findByUser').mockResolvedValue({ assistantid: 'asst1' } as any);
    vi.spyOn(KnowledgeBaseRepository, 'findByAssistant').mockResolvedValue([{ knowledgeid: 'doc1' }] as any);
    await expect(GetKnowledgeBase('usr1')).resolves.toEqual([{ knowledgeid: 'doc1' }]);

    await expect(DeleteDocument('')).rejects.toThrow('Knowledge ID is required');
    vi.spyOn(KnowledgeBaseRepository, 'findById').mockResolvedValue(null as any);
    await expect(DeleteDocument('doc1')).rejects.toThrow('Document not found');
    vi.spyOn(KnowledgeBaseRepository, 'findById').mockResolvedValue({ knowledgeid: 'doc1' } as any);
    vi.spyOn(KnowledgeBaseRepository, 'delete').mockResolvedValue({} as any);
    await expect(DeleteDocument('doc1')).resolves.toEqual({ message: 'Document deleted successfully' });
  });

  it('GenerateStudyPlan handles empty and populated task lists', async () => {
    await expect(GenerateStudyPlan({ userid: '' } as any)).rejects.toThrow('User ID is required');
    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([] as any);
    await expect(GenerateStudyPlan({ userid: 'usr1' })).resolves.toEqual({ plan: 'You have no pending tasks! Add some tasks first so I can create a study plan for you.' });

    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([{ title: 'Study', category: 'ACADEMIC', priority: 3, deadline: new Date('2026-01-02'), status: 'PENDING' }] as any);
    vi.spyOn(StudentMemoryRepository, 'findByUser').mockResolvedValue({ major: 'CS' });
    vi.spyOn(openai.chat.completions, 'create').mockResolvedValue({ choices: [{ message: { content: 'Plan output' } }] } as any);
    await expect(GenerateStudyPlan({ userid: 'usr1' })).resolves.toEqual({ plan: 'Plan output' });
  });

  it('AnalyzeWeakness handles empty history and persists weak categories', async () => {
    await expect(AnalyzeWeakness({ userid: '' } as any)).rejects.toThrow('User ID is required');
    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([] as any);
    await expect(AnalyzeWeakness({ userid: 'usr1' })).resolves.toEqual({ analysis: 'No task history yet. Complete some tasks so I can analyze your patterns!' });

    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([
      { category: 'ACADEMIC', status: 'OVERDUE' },
      { category: 'ACADEMIC', status: 'PENDING' },
      { category: 'WORK', status: 'COMPLETED' },
    ] as any);
    vi.spyOn(StudentMemoryRepository, 'findByUser').mockResolvedValue({ name: 'Imane', major: 'CS' });
    vi.spyOn(openai.chat.completions, 'create').mockResolvedValue({ choices: [{ message: { content: 'Weakness report' } }] } as any);
    const upsertSpy = vi.spyOn(StudentMemoryRepository, 'upsert').mockResolvedValue({} as any);
    await expect(AnalyzeWeakness({ userid: 'usr1' })).resolves.toEqual({ analysis: 'Weakness report' });
    expect(upsertSpy).toHaveBeenCalledWith('usr1', 'weak_subjects', 'ACADEMIC');
  });

  it('ScheduleFocusSession creates a session and links the suggested task', async () => {
    await expect(ScheduleFocusSession({ userid: '' } as any)).rejects.toThrow('User ID is required');
    vi.spyOn(StudentMemoryRepository, 'findByUser').mockResolvedValue({ preferred_study_time: 'morning' });
    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([{ taskid: 'tsk1', title: 'Study', priority: 3, deadline: new Date('2026-01-02') }] as any);
    vi.spyOn(openai.chat.completions, 'create').mockResolvedValue({ choices: [{ message: { content: '{"taskid":"tsk1","durationMinutes":50,"reason":"Highest priority"}' } }] } as any);
    vi.spyOn(FocusSessionRepository, 'create').mockResolvedValue({ sessionid: 'ssn1' } as any);
    vi.spyOn(prisma.sessiontask, 'create').mockResolvedValue({} as any);
    await expect(ScheduleFocusSession({ userid: 'usr1' })).resolves.toEqual({ sessionid: 'ssn1', suggestedTaskid: 'tsk1', durationMinutes: 50, reason: 'Highest priority', message: 'Focus session created! Open Neurova to start.' });
  });

  it('ProcessDocument validates required fields and indexes chunks', async () => {
    await expect(ProcessDocument({ userid: '', fileBuffer: Buffer.from('x') } as any)).rejects.toThrow('User ID is required');
    await expect(ProcessDocument({ userid: 'usr1', fileBuffer: null } as any)).rejects.toThrow('File is required');

    vi.spyOn(AssistantRepository, 'findOrCreate').mockResolvedValue({ assistantid: 'asst1' } as any);
    vi.spyOn(KnowledgeBaseRepository, 'create').mockResolvedValue({ knowledgeid: 'doc1' } as any);
    vi.spyOn(pdfChunker, 'extractTextFromFile').mockReturnValue('Hello world');
    vi.spyOn(pdfChunker, 'cleanText').mockReturnValue('Hello world');
    vi.spyOn(pdfChunker, 'chunkText').mockReturnValue(['chunk 1', 'chunk 2']);
    vi.spyOn(prisma.documentchunk, 'create').mockImplementation(async ({ data }: any) => ({ chunkid: `chk-${data.chunkindex}` }) as any);
    vi.spyOn(embeddingClient, 'getEmbeddings').mockResolvedValue([[0.1], [0.2]] as any);
    vi.spyOn(vectorClient, 'insertChunkWithEmbedding').mockResolvedValue(undefined as any);

    await expect(ProcessDocument({ userid: 'usr1', filename: 'notes.txt', fileBuffer: Buffer.from('Hello'), mimetype: 'text/plain' } as any)).resolves.toEqual({ documentid: 'doc1', filename: 'notes.txt', chunksCreated: 2, message: 'Document processed. 2 chunks indexed.' });
  });

  it('SendTaskReminders summarizes reminder sending', async () => {
    vi.spyOn(prisma.task, 'findMany').mockResolvedValue([
      { taskid: 'tsk1', title: 'Study', deadline: new Date('2026-01-02'), users: { email: 'a@test.com' } },
      { taskid: 'tsk2', title: 'Read', deadline: new Date('2026-01-02'), users: {} },
    ] as any);
    // Note: Brevo client is used for reminders, skipping mock
    await expect(SendTaskReminders('usr1')).resolves.toEqual({ remindersChecked: 2, remindersSent: 0, results: [] });
  });
});
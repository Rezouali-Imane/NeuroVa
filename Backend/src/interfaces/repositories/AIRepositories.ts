import prisma from '../../infrastructure/database/prisma.client.js';

const ensureAssistantIdForUser = async (userid: string): Promise<string> => {
  const existingProfile = await prisma.aiprofile.findUnique({
    where: { userid },
    include: { aiassistant: true },
  });

  if (existingProfile?.aiassistant?.assistantid) {
    return existingProfile.aiassistant.assistantid;
  }

  const assistant = await prisma.aiassistant.create({ data: {} });

  await prisma.aiprofile.create({
    data: {
      userid,
      assistantid: assistant.assistantid,
      supportedmajor: null,
      university: null,
    },
  });

  return assistant.assistantid;
};


export const ChatHistoryRepository = {

  async save(userid: string, role: 'USER' | 'ASSISTANT', content: string, assistantid?: string) {
    const resolvedAssistantId = assistantid ?? await ensureAssistantIdForUser(userid);

    return await prisma.chathistory.create({
      data: { userid, assistantid: resolvedAssistantId, role, content },
    });
  },

  async findByUser(userid: string, limit: number = 10) {
    return await prisma.chathistory.findMany({
      where: { userid },
      orderBy: { createdat: 'desc' },
      take: limit,
    });
  },

  async clearByUser(userid: string) {
    return await prisma.chathistory.deleteMany({ where: { userid } });
  },
};



export const StudentMemoryRepository = {

  async upsert(userid: string, key: string, value: string, assistantid?: string) {
    const resolvedAssistantId = assistantid ?? await ensureAssistantIdForUser(userid);

    return await prisma.studentmemory.upsert({
      where: { userid_key: { userid, key } },
      update: { value },
      create: { userid, assistantid: resolvedAssistantId, key, value },
    });
  },

  async findByUser(userid: string): Promise<Record<string, string>> {
    const memories = await prisma.studentmemory.findMany({ where: { userid } });
    return memories.reduce((acc, m) => {
      acc[m.key] = m.value;
      return acc;
    }, {} as Record<string, string>);
  },

  async findOne(userid: string, key: string) {
    return await prisma.studentmemory.findUnique({
      where: { userid_key: { userid, key } },
    });
  },

  async delete(userid: string, key: string) {
    return await prisma.studentmemory.delete({
      where: { userid_key: { userid, key } },
    });
  },
};


export const KnowledgeBaseRepository = {

  async create(data: {
    assistantid?: string;
    major?: string;
    subject?: string;
    filename?: string;
    fileurl?: string;
  }) {
    return await prisma.knowledgebase.create({ data });
  },

  async findByAssistant(assistantid: string) {
    return await prisma.knowledgebase.findMany({
      where: { assistantid },
      orderBy: { uploadedat: 'desc' },
    });
  },

  async findById(knowledgeid: string) {
    return await prisma.knowledgebase.findUnique({ where: { knowledgeid } });
  },

  async delete(knowledgeid: string) {
    return await prisma.knowledgebase.delete({ where: { knowledgeid } });
  },
};



export const AssistantRepository = {

  async findByUser(userid: string) {
    const profile = await prisma.aiprofile.findUnique({
      where: { userid },
      include: { aiassistant: { include: { knowledgebase: true } } },
    });

    return profile?.aiassistant ?? null;
  },

  async create(userid: string, supportmajor?: string) {
    const assistant = await prisma.aiassistant.create({ data: {} });

    await prisma.aiprofile.create({
      data: {
        userid,
        assistantid: assistant.assistantid,
        supportedmajor: supportmajor ?? null,
        university: null,
      },
    });

    return assistant;
  },

  async findOrCreate(userid: string, major?: string) {
    const existing = await AssistantRepository.findByUser(userid);
    if (existing) return existing;
    return await AssistantRepository.create(userid, major);
  },
};
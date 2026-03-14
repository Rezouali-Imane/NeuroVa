export interface Assistant {
  assistantid: string;
  userid: string;
  supportmajor?: string;
}

export type ChatRole = 'USER' | 'ASSISTANT';

export interface ChatHistory {
  chatid: string;
  userid: string;
  role: ChatRole;
  content: string;
  createdat: Date;
}

export interface KnowledgeBase {
  knowledgeid: string;
  assistantid?: string;
  major?: string;
  subject?: string;
  filename?: string;
  fileurl?: string;
  uploadedat: Date;
}

export interface StudentMemory {
  memoryid: string;
  userid: string;
  key: string;
  value: string;
  updatedat: Date;
}

export interface DocumentChunk {
  chunkid: string;
  knowledgeid?: string;
  userid: string;
  content: string;
  chunkindex?: number;
  uploadedat: Date;
}
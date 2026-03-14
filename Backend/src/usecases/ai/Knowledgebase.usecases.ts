import { KnowledgeBaseRepository, AssistantRepository } from '../../interfaces/repositories/AIRepositories.js';

export const GetKnowledgeBase = async (userid: string) => {
  if (!userid) throw new Error('User ID is required');
  const assistant = await AssistantRepository.findByUser(userid);
  if (!assistant) return [];
  return await KnowledgeBaseRepository.findByAssistant(assistant.assistantid);
};

export const DeleteDocument = async (knowledgeid: string) => {
  if (!knowledgeid) throw new Error('Knowledge ID is required');
  const doc = await KnowledgeBaseRepository.findById(knowledgeid);
  if (!doc) throw new Error('Document not found');
  await KnowledgeBaseRepository.delete(knowledgeid);
  return { message: 'Document deleted successfully' };
};
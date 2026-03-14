import { ChatHistoryRepository } from '../../interfaces/repositories/AIRepositories.js';

export const ClearChatHistory = async (userid: string) => {
  if (!userid) throw new Error('User ID is required');
  await ChatHistoryRepository.clearByUser(userid);
  return { message: 'Chat history cleared successfully' };
};
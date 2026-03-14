import { ChatHistoryRepository } from '../../interfaces/repositories/AIRepositories.js';

export const GetChatHistory = async (userid: string) => {
  if (!userid) throw new Error('User ID is required');
  const history = await ChatHistoryRepository.findByUser(userid, 50);
  return history.reverse(); // oldest first for display
};
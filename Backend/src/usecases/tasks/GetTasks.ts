import { TaskRepository } from '../../interfaces/repositories/TaskRepository.js';

export const GetTasks = async (userid: string) => {
  if (!userid) {
    throw new Error('User ID is required');
  }
  return await TaskRepository.findAllByUser(userid);
};
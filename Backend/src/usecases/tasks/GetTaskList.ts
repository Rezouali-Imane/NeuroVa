import { TaskListRepository } from '../../interfaces/repositories/TaskListRepository.js';

export const GetTaskList = async (userid: string) => {
  if (!userid) {
    throw new Error('User ID is required');
  }
  return await TaskListRepository.findAllByUser(userid);
};
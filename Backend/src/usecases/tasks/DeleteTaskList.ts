import { TaskListRepository } from '../../interfaces/repositories/TaskListRepository.js';

export const DeleteTaskList = async (listid: string) => {
  const list = await TaskListRepository.findById(listid);
  if (!list) {
    throw new Error('Task list not found');
  }
  return await TaskListRepository.delete(listid);
};
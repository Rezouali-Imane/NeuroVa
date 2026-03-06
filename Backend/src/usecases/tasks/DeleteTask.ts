import { TaskRepository } from '../../interfaces/repositories/TaskRepository.js';

export const DeleteTask = async (taskid: string) => {
  const task = await TaskRepository.findById(taskid);
  if (!task) {
    throw new Error('Task not found');
  }
  return await TaskRepository.delete(taskid);
};
import { TaskRepository } from '../../interfaces/repositories/TaskRepository.js';
import type { UpdateTaskDTO } from '../../interfaces/dtos/Task.dto.js';

export const UpdateTask = async (taskid: string, data: UpdateTaskDTO) => {
  const task = await TaskRepository.findById(taskid);
  if (!task) {
    throw new Error('Task not found');
  }
  return await TaskRepository.update(taskid, data);
};
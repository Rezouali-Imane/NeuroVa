import { TaskRepository } from '../../interfaces/repositories/TaskRepository.js';
import type { UpdateTaskStatusDTO } from '../../interfaces/dtos/Task.dto.js';

export const UpdateTaskStatus = async (taskid: string, data: UpdateTaskStatusDTO) => {
  const task = await TaskRepository.findById(taskid);
  if (!task) {
    throw new Error('Task not found');
  }
  return await TaskRepository.updateStatus(taskid, data.status);
};
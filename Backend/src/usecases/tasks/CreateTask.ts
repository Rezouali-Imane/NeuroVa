import { TaskRepository } from '../../interfaces/repositories/TaskRepository.js';
import type { CreateTaskDTO } from '../../interfaces/dtos/Task.dto.js';

export const CreateTask = async (data: CreateTaskDTO) => {
  if (!data.title || data.title.trim() === '') {
    throw new Error('Task title is required');
  }
  if (!data.userid) {
    throw new Error('User ID is required');
  }
  if (!data.listid) {
    throw new Error('Task list ID is required');
  }
  return await TaskRepository.create(data);
};
import { TaskListRepository } from '../../interfaces/repositories/TaskListRepository.js';
import type { CreateTaskListDTO } from '../../interfaces/dtos/TaskList.dto.js';

export const CreateTaskList = async (data: CreateTaskListDTO) => {
  if (!data.name || data.name.trim() === '') {
    throw new Error('Task list name is required');
  }
  if (!data.userid) {
    throw new Error('User ID is required');
  }
  return await TaskListRepository.create(data);
};
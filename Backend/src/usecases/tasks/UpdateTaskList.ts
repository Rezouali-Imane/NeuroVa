import { TaskListRepository } from '../../interfaces/repositories/TaskListRepository.js';
import type { UpdateTaskListDTO } from '../../interfaces/dtos/TaskList.dto.js';

export const UpdateTaskList = async (listid: string, data: UpdateTaskListDTO) => {
  const list = await TaskListRepository.findById(listid);
  if (!list) {
    throw new Error('Task list not found');
  }
  return await TaskListRepository.update(listid, data);
};
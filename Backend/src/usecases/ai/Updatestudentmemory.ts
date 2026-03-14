import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';
import type { UpdateMemoryDTO } from '../../interfaces/dtos/AI.dto.js';

export const UpdateStudentMemory = async (data: UpdateMemoryDTO) => {
  if (!data.userid) throw new Error('User ID is required');
  if (!data.key) throw new Error('Memory key is required');
  if (!data.value) throw new Error('Memory value is required');

  await StudentMemoryRepository.upsert(data.userid, data.key, data.value);
  return { message: 'Memory updated', key: data.key, value: data.value };
};
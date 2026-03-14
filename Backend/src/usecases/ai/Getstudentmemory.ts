import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';

export const GetStudentMemory = async (userid: string) => {
  if (!userid) throw new Error('User ID is required');
  const memory = await StudentMemoryRepository.findByUser(userid);
  return { memory };
};
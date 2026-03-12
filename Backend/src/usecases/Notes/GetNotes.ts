import { NoteRepository } from '../../interfaces/repositories/NoteRepository.js';

export const GetNotes = async (userid: string) => {
  if (!userid) {
    throw new Error('User ID is required');
  }
  return await NoteRepository.findAllByUser(userid);
};
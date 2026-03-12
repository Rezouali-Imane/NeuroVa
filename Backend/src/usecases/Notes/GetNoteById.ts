import { NoteRepository } from '../../interfaces/repositories/NoteRepository.js';

export const GetNoteById = async (noteid: string) => {
  const note = await NoteRepository.findById(noteid);
  if (!note) {
    throw new Error('Note not found');
  }
  return note;
};
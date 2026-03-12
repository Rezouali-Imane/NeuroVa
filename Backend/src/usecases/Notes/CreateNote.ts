import { NoteRepository } from '../../interfaces/repositories/NoteRepository.js';
import type { CreateNoteDTO } from '../../interfaces/dtos/Note.dto.js';

export const CreateNote = async (data: CreateNoteDTO) => {
  if (!data.title || data.title.trim() === '') {
    throw new Error('Note title is required');
  }
  if (!data.userid) {
    throw new Error('User ID is required');
  }
  return await NoteRepository.create(data);
};
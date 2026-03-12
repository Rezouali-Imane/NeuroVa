import { NoteRepository } from '../../interfaces/repositories/NoteRepository.js';
import type { UpdateNoteDTO } from '../../interfaces/dtos/Note.dto.js';

export const UpdateNote = async (noteid: string, data: UpdateNoteDTO) => {
  const note = await NoteRepository.findById(noteid);
  if (!note) {
    throw new Error('Note not found');
  }
  return await NoteRepository.update(noteid, data);
};
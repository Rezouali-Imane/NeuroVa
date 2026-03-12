import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateNoteDTO, UpdateNoteDTO } from '../dtos/Note.dto.js';

export const NoteRepository = {

  async create(data: CreateNoteDTO) {
    return await prisma.note.create({
      data: {
        userid: data.userid,
        title: data.title,
        content: data.content ?? null,
      },
    });
  },

  async findAllByUser(userid: string) {
    return await prisma.note.findMany({
      where: { userid },
      orderBy: { createdat: 'desc' },
    });
  },

  async findById(noteid: string) {
    return await prisma.note.findUnique({
      where: { noteid },
    });
  },

  async update(noteid: string, data: UpdateNoteDTO) {
    return await prisma.note.update({
      where: { noteid },
      data,
    });
  },

  async delete(noteid: string) {
    return await prisma.note.delete({
      where: { noteid },
    });
  },
};
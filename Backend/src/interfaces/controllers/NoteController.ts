import type { Request, Response } from 'express';
import { CreateNote } from '../../usecases/Notes/CreateNote.js';
import { GetNotes } from '../../usecases/Notes/GetNotes.js';
import { GetNoteById } from '../../usecases/Notes/GetNoteById.js';
import { UpdateNote } from '../../usecases/Notes/UpdateNote.js';
import { DeleteNote } from '../../usecases/Notes/DeleteNote.js';

export const NoteController = {

  async create(req: Request, res: Response) {
    try {
      const note = await CreateNote(req.body);
      res.status(201).json({ success: true, data: note });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAll(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const notes = await GetNotes(userid);
      res.status(200).json({ success: true, data: notes });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const noteid = req.params['noteid'] as string;
      const note = await GetNoteById(noteid);
      res.status(200).json({ success: true, data: note });
    } catch (error: any) {
      res.status(404).json({ success: false, message: error.message });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const noteid = req.params['noteid'] as string;
      const note = await UpdateNote(noteid, req.body);
      res.status(200).json({ success: true, data: note });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      const noteid = req.params['noteid'] as string;
      await DeleteNote(noteid);
      res.status(200).json({ success: true, message: 'Note deleted successfully' });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },
};
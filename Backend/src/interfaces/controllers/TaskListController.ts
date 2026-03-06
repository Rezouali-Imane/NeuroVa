import type { Request, Response } from 'express';
import { CreateTaskList } from '../../usecases/tasks/CreateTaskList.js';
import { GetTaskList } from '../../usecases/tasks/GetTaskList.js';
import { UpdateTaskList } from '../../usecases/tasks/UpdateTaskList.js';
import { DeleteTaskList } from '../../usecases/tasks/DeleteTaskList.js';

export const TaskListController = {

  async create(req: Request, res: Response) {
    try {
      const list = await CreateTaskList(req.body);
      res.status(201).json({ success: true, data: list });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAll(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const lists = await GetTaskList(userid);
      res.status(200).json({ success: true, data: lists });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const listid = req.params['listid'] as string;
      const list = await UpdateTaskList(listid, req.body);
      res.status(200).json({ success: true, data: list });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      const listid = req.params['listid'] as string;
      await DeleteTaskList(listid);
      res.status(200).json({ success: true, message: 'Task list deleted successfully' });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },
};
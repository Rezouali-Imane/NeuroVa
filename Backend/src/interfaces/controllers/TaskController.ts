import type { Request, Response } from 'express';
import { CreateTask } from '../../usecases/tasks/CreateTask.js';
import { GetTasks } from '../../usecases/tasks/GetTasks.js';
import { GetTaskById } from '../../usecases/tasks/GetTaskById.js';
import { UpdateTask } from '../../usecases/tasks/UpdateTask.js';
import { UpdateTaskStatus } from '../../usecases/tasks/UpdateTaskStatus.js';
import { DeleteTask } from '../../usecases/tasks/DeleteTask.js';

export const TaskController = {

  async create(req: Request, res: Response) {
    try {
      const task = await CreateTask(req.body);
      res.status(201).json({ success: true, data: task });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAll(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const tasks = await GetTasks(userid);
      res.status(200).json({ success: true, data: tasks });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const taskid = req.params['taskid'] as string;
      const task = await GetTaskById(taskid);
      res.status(200).json({ success: true, data: task });
    } catch (error: any) {
      res.status(404).json({ success: false, message: error.message });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const taskid = req.params['taskid'] as string;
      const task = await UpdateTask(taskid, req.body);
      res.status(200).json({ success: true, data: task });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateStatus(req: Request, res: Response) {
    try {
      const taskid = req.params['taskid'] as string;
      const task = await UpdateTaskStatus(taskid, req.body);
      res.status(200).json({ success: true, data: task });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      const taskid = req.params['taskid'] as string;
      await DeleteTask(taskid);
      res.status(200).json({ success: true, message: 'Task deleted successfully' });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },
};
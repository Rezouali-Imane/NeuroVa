import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateTaskDTO, UpdateTaskDTO } from '../dtos/Task.dto.js';
import { TaskStatus } from '../../entities/Task.js';

export const TaskRepository = {

  async create(data: CreateTaskDTO) {
    return await prisma.task.create({
      data: {
        userid: data.userid,
        listid: data.listid,
        title: data.title,
        description: data.description ?? null,
        deadline: data.deadline ?? null,
        priority: data.priority ?? 0,
        category: data.category ?? 'PERSONAL',
        syncwithgoogle: data.syncwithgoogle ?? false,
      },
    });
  },

  async findAllByUser(userid: string) {
    return await prisma.task.findMany({
      where: { userid },
      orderBy: { createdat: 'desc' },
    });
  },

  async findById(taskid: string) {
    return await prisma.task.findUnique({
      where: { taskid },
    });
  },

  async update(taskid: string, data: UpdateTaskDTO) {
    return await prisma.task.update({
      where: { taskid },
      data,
    });
  },

  async updateStatus(taskid: string, status: TaskStatus) {
    return await prisma.task.update({
      where: { taskid },
      data: { status },
    });
  },

  async delete(taskid: string) {
    return await prisma.task.delete({
      where: { taskid },
    });
  },
};
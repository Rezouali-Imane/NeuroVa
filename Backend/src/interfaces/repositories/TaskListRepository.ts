import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateTaskListDTO, UpdateTaskListDTO } from '../dtos/TaskList.dto.js';

export const TaskListRepository = {

  async create(data: CreateTaskListDTO) {
    const createData = {
      userid: data.userid,
      name: data.name,
      ...(data.scheduleid ? { scheduleid: data.scheduleid } : {}),
    };

    return await prisma.tasklist.create({
      data: createData,
    });
  },

  async findAllByUser(userid: string) {
    return await prisma.tasklist.findMany({
      where: { userid },
      include: { task: true },
      orderBy: { createdat: 'desc' },
    });
  },

  async findById(listid: string) {
    return await prisma.tasklist.findUnique({
      where: { listid },
      include: { task: true },
    });
  },

  async update(listid: string, data: UpdateTaskListDTO) {
    return await prisma.tasklist.update({
      where: { listid },
      data,
    });
  },

  async delete(listid: string) {
    return await prisma.tasklist.delete({
      where: { listid },
    });
  },
};
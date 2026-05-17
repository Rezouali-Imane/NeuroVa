import prisma from "../../infrastructure/database/prisma.client.js";
import type { CreateTimerDTO } from "../dtos/Timer.dto.js";

export const TimerRepository = {
  async create(data: CreateTimerDTO) {
    return await prisma.timer.create({
      data: {
        sessionid: data.sessionid,
        type: data.type,
        durationminutes: data.durationminutes,
        breakminutes: data.breakminutes ?? 0,
        longbreakminutes: data.longbreakminutes ?? 0,
        pomodorocycles: data.pomodorocycles ?? 0,
        isrunning: data.isrunning,
        remainingseconds: data.remainingseconds,
        starttime: data.starttime ?? null,
        endtime: data.endtime ?? null,
      },
    });
  },

  async findById(timerid: string) {
    return await prisma.timer.findUnique({
      where: { timerid },
    });
  },

  async update(timerid: string, data: any) {
    const updateData: any = {};
    if (data.starttime !== undefined)
      updateData.starttime = data.starttime ?? null;
    if (data.endtime !== undefined) updateData.endtime = data.endtime ?? null;
    if (data.isrunning !== undefined) updateData.isrunning = data.isrunning;
    if (data.remainingseconds !== undefined)
      updateData.remainingseconds = data.remainingseconds;
    if (data.durationminutes !== undefined)
      updateData.durationminutes = data.durationminutes;
    if (data.breakminutes !== undefined)
      updateData.breakminutes = data.breakminutes ?? 0;
    if (data.longbreakminutes !== undefined)
      updateData.longbreakminutes = data.longbreakminutes ?? 0;
    if (data.pomodorocycles !== undefined)
      updateData.pomodorocycles = data.pomodorocycles ?? 0;
    if (data.type !== undefined) updateData.type = data.type;

    return await prisma.timer.update({
      where: { timerid },
      data: updateData,
    });
  },

  async delete(timerid: string) {
    return await prisma.timer.delete({
      where: { timerid },
    });
  },

  async findManyBySession(sessionid: string) {
    return await prisma.timer.findMany({
      where: { sessionid },
    });
  },
};

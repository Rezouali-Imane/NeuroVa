import prisma from "../../infrastructure/database/prisma.client.js";
import type { CreateTimerDTO, UpdateTimerDTO } from "../dtos/Timer.dto.js";

export const TimerRepository = {
    async create(data: CreateTimerDTO) {
        return await prisma.timer.create({
            data: {
                sessionid: data.sessionid,
                type: data.type, 
                durationminutes: data.durationminutes,
                breakminutes: data.breakminutes,
                longbreakminutes: data.longbreakminutes,
                pomodoroscycle: data.pomodoroscycle,
                remainingseconds: data.remainingseconds, 
                isrunning: data.isrunning ?? false
            },
        });
    },

    async findBySessionId(sessionid: string) {
        return await prisma.timer.findUnique({
            where: { sessionid },
        });
    },

    async update(sessionid: string, data: UpdateTimerDTO) {
        const updateData = {
            ...(data.type !== undefined || (data as any).timertype !== undefined
                ? { type: data.type ?? (data as any).timertype }
                : {}),
            ...(data.durationminutes !== undefined ? { durationminutes: data.durationminutes } : {}),
            ...(data.breakminutes !== undefined ? { breakminutes: data.breakminutes } : {}),
            ...(data.longbreakminutes !== undefined ? { longbreakminutes: data.longbreakminutes } : {}),
            ...(data.pomodoroscycle !== undefined ? { pomodoroscycle: data.pomodoroscycle } : {}),
            ...(data.remainingseconds !== undefined ? { remainingseconds: data.remainingseconds } : {}),
            ...(data.isrunning !== undefined ? { isrunning: data.isrunning } : {}),
            ...(data.starttime !== undefined ? { starttime: data.starttime } : {}),
            ...(data.endtime !== undefined ? { endtime: data.endtime } : {})
        };

        return await prisma.timer.update({
            where: { sessionid },
            data: updateData,
        });
    },

    async delete(sessionid: string) {
        return await prisma.timer.delete({
            where: { sessionid },
        });
    }
};
import prisma from "../../infrastructure/database/prisma.client.js";
import type { CreateFocusSessionDTO, UpdateFocusSessionDTO } from "../dtos/FocusSession.dto.js";

export const FocusSessionRepository = {
    async create(data: CreateFocusSessionDTO) {
        return await prisma.focussession.create({
            data,
        });
    },

    async findAllByUser(userid: string) {
        return await prisma.focussession.findMany({
            where: { userid },
            orderBy: { starttime: 'desc' },
        });
    },

    async findById(id: string) {
        return await prisma.focussession.findUnique({
            where: { sessionid: id },
        });
    },

    async update(sessionid: string, data: UpdateFocusSessionDTO) {
        return await prisma.focussession.update({
            where: { sessionid },
            data,
        });
    },

    async delete(sessionid: string) {
        return await prisma.focussession.delete({
            where: { sessionid },
        });
    },
};
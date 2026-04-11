import prisma from "../../infrastructure/database/prisma.client.js";
import type { CreateFocusSessionDTO, UpdateFocusSessionDTO , CalculateFocusScoreDTO} from "../dtos/FocusSession.dto.js";

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

    async findById(sessionid: string) {
        return await prisma.focussession.findUnique({
            where: { sessionid },
        });
    },

    async update(sessionid: string, updateData: UpdateFocusSessionDTO) {
        return await prisma.focussession.update({
            where: { sessionid },
            data: updateData,
        });
    },

    async delete(sessionid: string) {
        return await prisma.focussession.delete({
            where: { sessionid },
        });
    },
    
    async calculateFocusScore(calculateFocusScoreData: CalculateFocusScoreDTO) {
        return await prisma.focussession.update({
            where: { sessionid: calculateFocusScoreData.sessionid },
            data: { focusscore: calculateFocusScoreData.focusscore },
        });
    }  
};
import prisma from "../../infrastructure/database/prisma.client.js";
import type { CreateFocusAudioDTO } from "../dtos/FocusAudio.dto.js";

export const FocusAudioRepository = {
  
    async create(data: CreateFocusAudioDTO) {
        const createData = {
            sessionid: data.sessionid,
            volumelevel: data.volumelevel ?? 1.0,
            mixambientsounds: data.mixambientsounds ?? false,
            ...(data.sounds && data.sounds.length > 0 ? { ambientsound: { create: data.sounds } } : {}),
        };

        return await prisma.focusaudiosettings.create({
            data: createData,
            include: { 
                ambientsound: true 
            }
        });
    },

   
    async findBySessionId(sessionid: string) {
        return await prisma.focusaudiosettings.findUnique({
            where: { sessionid }, // sessionid is unique in the schema 
            include: { 
                ambientsound: true 
            }
        });
    }
};
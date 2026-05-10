import prisma from "../../infrastructure/database/prisma.client.js";
import type {
    CreateFocusAudioDTO,
    CreateAmbientSoundDTO,
    UpdateFocusAudioSettingsDTO,
    DeleteAmbientSoundDTO,
    DeleteFocusAudioSettingsDTO,
} from "../dtos/FocusAudio.dto.js";

export const FocusAudioRepository = {
    async create(data: CreateFocusAudioDTO) {
    const createData = {
        sessionid: data.sessionid,
        volumelevel: data.volumelevel ?? 1.0,
        mixmultiplesounds: data.mixmultiplesounds ?? false,
        ...(data.sounds && data.sounds.length > 0
            ? {
                ambientsound: {
                    create: data.sounds.map(sound => ({
                        name: sound.name,
                        ...(sound.audiourl !== undefined ? { audiourl: sound.audiourl } : {}),
                        islooping: sound.islooping ?? false
                    }))
                }
            }
            : {})
    };

    return await prisma.focusaudiosettings.create({
        data: createData,
        include: { ambientsound: true }
    });
},
    async findBySessionId(sessionid: string) {
        return await prisma.focusaudiosettings.findUnique({
            where: { sessionid },
            include: { ambientsound: true }
        });
    },

    async findById(settingsid: string) {
        return await prisma.focusaudiosettings.findUnique({
            where: { settingsid },
            include: { ambientsound: true },
        });
    },

    async findManyBySession(sessionid: string) {
        return await prisma.focusaudiosettings.findMany({
            where: { sessionid },
            include: { ambientsound: true },
        });
    },

    async createAmbientSound(settingsid: string, soundData: CreateAmbientSoundDTO) {
        return await prisma.ambientsound.create({
            data: {
                settingsid,
                name: soundData.name,
                ...(soundData.audiourl !== undefined ? { audiourl: soundData.audiourl } : {}),
                islooping: soundData.islooping ?? false
            }
        });
    },

    async updateAmbientSound(soundid: string, soundData: CreateAmbientSoundDTO) {
        const updateData = {
            ...(soundData.name !== undefined ? { name: soundData.name } : {}),
            ...(soundData.audiourl !== undefined ? { audiourl: soundData.audiourl } : {}),
            ...(soundData.islooping !== undefined ? { islooping: soundData.islooping } : {})
        };

        return await prisma.ambientsound.update({
            where: { soundid },
            data: updateData
        });
    },

    async findAmbientSoundById(soundid: string) {
        return await prisma.ambientsound.findUnique({
            where: { soundid },
        });
    },

    async findSoundsBySettings(settingsid: string) {
        return await prisma.ambientsound.findMany({
            where: { settingsid },
        });
    },

    async updateAmbientSoundLooping(soundid: string, islooping: boolean) {
        return await prisma.ambientsound.update({
            where: { soundid },
            data: { islooping }
        });
    },

    async updateSettings(settingsid: string, data: UpdateFocusAudioSettingsDTO) {
        const updateData = {
            ...(data.volumelevel !== undefined ? { volumelevel: data.volumelevel } : {}),
            ...(data.mixmultiplesounds !== undefined ? { mixmultiplesounds: data.mixmultiplesounds } : {})
        };

        return await prisma.focusaudiosettings.update({
            where: { settingsid },
            data: updateData
        });
    },

    async delete(data: DeleteFocusAudioSettingsDTO) {
        return await prisma.focusaudiosettings.delete({
            where: { settingsid: data.settingsid },
        });
    },

    async deleteAmbientSound(sound: string | DeleteAmbientSoundDTO) {
        const soundid = typeof sound === "string" ? sound : sound.soundid;
        return await prisma.ambientsound.delete({
            where: { soundid }
        });
    }
};
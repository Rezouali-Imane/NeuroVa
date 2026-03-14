import prisma from "../../infrastructure/database/prisma.client.js";
import type {CreateFocusAudioDTO,CreateAmbientSoundDTO, UpdateFocusAudioSettingsDTO } from "../dtos/FocusAudio.dto.js";

export const FocusAudioRepository = {
    async create(data: CreateFocusAudioDTO) {
    const createData = {
        sessionid: data.sessionid,
        volumelevel: data.volumelevel ?? 1.0,
        mixambientsounds: data.mixambientsounds ?? false,
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

    async handleAmbientSound(sessionid: string, soundData: CreateAmbientSoundDTO) {
        
        const settings = await this.findBySessionId(sessionid);
        if (!settings) throw new Error("Audio settings not found for this session.");

        // MODIFY (The user provided a specific ID)
        if (soundData.soundid) {
            const updateData = {
                ...(soundData.name !== undefined ? { name: soundData.name } : {}),
                ...(soundData.audiourl !== undefined ? { audiourl: soundData.audiourl } : {}),
                ...(soundData.islooping !== undefined ? { islooping: soundData.islooping } : {}),
            };

            return await prisma.ambientsound.update({
                where: { soundid: soundData.soundid },
                data: updateData
            });
        }

        // check if sound existe
        const existingSound = settings.ambientsound.find(
            s => s.name === soundData.name && s.audiourl === soundData.audiourl
        );

        if (existingSound) {
            // Update the existing sound 
            return await prisma.ambientsound.update({
                where: { soundid: existingSound.soundid },
                data: { islooping: soundData.islooping ?? false }
            });
        }

        //  CREATE a new sound
        return await prisma.ambientsound.create({
            data: {
                settingsid: settings.settingsid,
                name: soundData.name,
                ...(soundData.audiourl !== undefined ? { audiourl: soundData.audiourl } : {}),
                islooping: soundData.islooping ?? false
            }
        });
    },

    async updateSettings(sessionid: string, data: UpdateFocusAudioSettingsDTO) {
        const updateData = {
            ...(data.volumelevel !== undefined ? { volumelevel: data.volumelevel } : {}),
            ...(data.mixambientsounds !== undefined ? { mixambientsounds: data.mixambientsounds } : {}),
        };

        return await prisma.focusaudiosettings.update({
            where: { sessionid },
            data: updateData
        });
    },

    async deleteAmbientSound(soundid: string) {
        return await prisma.ambientsound.delete({
            where: { soundid }
        });
    }
};
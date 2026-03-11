import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingRepository.js";
import type { CreateFocusAudioDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const CreateFocusAudio = async (data: CreateFocusAudioDTO) => {
    
    if (!data.sessionid) {
        throw new Error("A Session ID is required to initialize audio settings.");
    }

    
    const audioData: CreateFocusAudioDTO = {
        sessionid: data.sessionid,
        volumelevel: data.volumelevel ?? 1.0, // default value 1.0 volume (if user didnt enter anything)
        mixambientsounds: data.mixambientsounds ?? false,
        sounds: data.sounds ?? [] 
    };

    const newAudioSetting = await FocusAudioRepository.create(audioData);

    return newAudioSetting;
};
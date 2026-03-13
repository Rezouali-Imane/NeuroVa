import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { CreateAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const UpdateAmbientSound = async (sessionid: string, soundData: CreateAmbientSoundDTO) => {
    if (!sessionid) throw new Error("Session ID is required.");
    if (!soundData.soundid) throw new Error("Sound ID is required for update.");

    const settings = await FocusAudioRepository.findBySessionId(sessionid);
    if (!settings) throw new Error("Audio settings not found for this session.");

    const sound = await FocusAudioRepository.updateAmbientSound(soundData.soundid, soundData);
    return { success: true, message: `Sound "${soundData.name}" modified.`, data: sound };
};
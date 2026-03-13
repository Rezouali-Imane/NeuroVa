import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { CreateAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const CreateAmbientSound = async (sessionid: string, soundData: CreateAmbientSoundDTO) => {
    if (!sessionid) throw new Error("Session ID is required.");

    const settings = await FocusAudioRepository.findBySessionId(sessionid);
    if (!settings) throw new Error("Audio settings not found for this session.");

    const existingSound = settings.ambientsound.find(
        s => s.name === soundData.name && s.audiourl === (soundData.audiourl ?? null)
    );

    if (existingSound) {
        const sound = await FocusAudioRepository.updateAmbientSoundLooping(
            existingSound.soundid,
            soundData.islooping ?? false
        );

        return { success: true, message: `Sound "${soundData.name}" modified.`, data: sound };
    }

    const sound = await FocusAudioRepository.createAmbientSound(settings.settingsid, soundData);
    return { success: true, message: `Sound "${soundData.name}" added.`, data: sound };
};
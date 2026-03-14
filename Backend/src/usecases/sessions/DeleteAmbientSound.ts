import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { DeleteAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const RemoveAmbientSound = async (data: DeleteAmbientSoundDTO) => {
    if (!data.soundid) {
        throw new Error("Sound ID is required.");
    }

    return await FocusAudioRepository.deleteAmbientSound(data); 
};
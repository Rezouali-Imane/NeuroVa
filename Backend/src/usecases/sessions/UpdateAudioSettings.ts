import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { 
    UpdateFocusAudioSettingsDTO
} from "../../interfaces/dtos/FocusAudio.dto.js";

// for updatng the setting(Volume/soundMix)
export const UpdateAudioSettings = async (sessionid: string, data: UpdateFocusAudioSettingsDTO) => {
    if (!sessionid) throw new Error("Session ID is required.");
    if (data.volumelevel !== undefined) {
    
        data.volumelevel = Math.max(0, Math.min(1, data.volumelevel));
    }
    const settings = await FocusAudioRepository.updateSettings(sessionid, data);
    return { success: true, message: "Settings updated.", data: settings };
};

// Delete ambient sound
export const RemoveAmbientSound = async (soundid: string) => {
    if (!soundid) throw new Error("Sound ID is required.");
    
    await FocusAudioRepository.deleteAmbientSound(soundid);
    return { success: true, message: "Sound deleted." };
};
import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { DeleteFocusAudioSettingsDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const DeleteAudioSettings = async (data: DeleteFocusAudioSettingsDTO) => {
    if (!data.settingsid) throw new Error("Settings ID is required.");
    return await FocusAudioRepository.delete(data); 
};
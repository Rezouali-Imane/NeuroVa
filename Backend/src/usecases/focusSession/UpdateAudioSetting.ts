import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingRepository.js";
import type { UpdateFocusAudioSettingsDTO, CreateAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const UpdateFocusAudio = async (
    sessionid: string, 
    settingsData?: UpdateFocusAudioSettingsDTO, //for changing volume and ambientsoundmix
    newSound?: CreateAmbientSoundDTO //for crearing a new ambient sound
) => {
    if (!sessionid) {
        throw new Error("Session ID is required for any audio update.");
    }

    let updatedResult: any = {};

    if (settingsData) {
        
        if (settingsData.volumelevel !== undefined && (settingsData.volumelevel < 0 || settingsData.volumelevel > 1)) {
            throw new Error("Volume must be between 0 and 1.");
        }
        updatedResult.settings = await FocusAudioRepository.updateSettings(sessionid, settingsData);
    }

    if (newSound) {
        // name and url are obligatory
        if (!newSound.name || !newSound.audiourl) {
            throw new Error("Both name and audiourl are obligatory to add an ambient sound.");
        }

        const soundToCreate: CreateAmbientSoundDTO = {
            ...newSound,
            islooping: newSound.islooping ?? true // Default to true
        };

        updatedResult.addedSound = await FocusAudioRepository.addAmbientSound(sessionid, soundToCreate);
    }

    // Returning success status and data
    return {
        success: true,
        message: "Update successful",
        data: updatedResult
    };
};
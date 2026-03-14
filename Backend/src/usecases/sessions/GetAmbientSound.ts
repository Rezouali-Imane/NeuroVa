import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";

export const GetAmbientSoundById = async (soundid: string) => {
    if (!soundid) throw new Error("Sound ID is required.");
    const sound = await FocusAudioRepository.findAmbientSoundById(soundid);
    if (!sound) throw new Error("Ambient sound not found.");
    return sound;
};

export const GetAmbientSoundsBySettings = async (settingsid: string) => {
    if (!settingsid) throw new Error("Settings ID is required.");
    return await FocusAudioRepository.findSoundsBySettings(settingsid);
};
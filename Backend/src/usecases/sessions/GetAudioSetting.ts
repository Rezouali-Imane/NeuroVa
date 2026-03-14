import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";

export const GetAudioById = async (settingsid: string) => {
    if (!settingsid) throw new Error("Settings ID is required.");
    const settings = await FocusAudioRepository.findById(settingsid); 
    if (!settings) throw new Error("Audio settings not found.");
    return settings;
};

export const GetAudioBySession = async (sessionid: string) => {
    if (!sessionid) throw new Error("Session ID is required.");
    return await FocusAudioRepository.findManyBySession(sessionid);
};
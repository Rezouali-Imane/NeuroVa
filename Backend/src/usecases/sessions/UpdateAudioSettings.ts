import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { UpdateFocusAudioSettingsDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const UpdateAudioSettings = async (
  settingsid: string,
  data: UpdateFocusAudioSettingsDTO,
) => {
  if (!settingsid) throw new Error("Settings ID is required.");

  if (data.volumelevel !== undefined) {
    data.volumelevel = Math.max(0, Math.min(1, data.volumelevel));
  }

  const settings = await FocusAudioRepository.updateSettings(settingsid, data);
  return { success: true, message: "Settings updated.", data: settings };
};

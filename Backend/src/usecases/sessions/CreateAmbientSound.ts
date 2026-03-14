import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { CreateAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const CreateAmbientSound = async (
  settingsid: string,
  soundData: CreateAmbientSoundDTO,
) => {
  if (!settingsid) throw new Error("Settings ID is required.");

  const sound = await FocusAudioRepository.createAmbientSound(
    settingsid,
    soundData,
  );

  return {
    success: true,
    message: `Sound "${soundData.name}" added.`,
    data: sound,
  };
};

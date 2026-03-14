import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { CreateAmbientSoundDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const UpdateAmbientSound = async (
  soundid: string,
  soundData: CreateAmbientSoundDTO,
) => {
  if (!soundid) throw new Error("Sound ID is required for update.");

  const sound = await FocusAudioRepository.updateAmbientSound(
    soundid,
    soundData,
  );

  return {
    success: true,
    message: `Sound "${sound.name}" modified.`,
    data: sound,
  };
};

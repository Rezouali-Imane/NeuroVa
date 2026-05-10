import { FocusAudioRepository } from "../../interfaces/repositories/FocusAudioSettingsRepository.js";
import type { CreateFocusAudioDTO } from "../../interfaces/dtos/FocusAudio.dto.js";

export const CreateFocusAudio = async (
  sessionid: string,
  customData?: Partial<CreateFocusAudioDTO>,
) => {
  if (!sessionid) {
    throw new Error("A Session ID is required to initialize audio settings.");
  }

  const audioData: CreateFocusAudioDTO = {
    sessionid: sessionid,
    volumelevel: customData?.volumelevel ?? 1.0,
    mixmultiplesounds: customData?.mixmultiplesounds ?? false,
    sounds: customData?.sounds ?? [],
  };

  return await FocusAudioRepository.create(audioData);
};

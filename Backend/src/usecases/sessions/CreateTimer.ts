// CreateTimer.ts
import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";
import { TimerType } from "../../entities/Timer.js";
import type { CreateTimerDTO } from "../../interfaces/dtos/Timer.dto.js";

export const CreateTimer = async (
  sessionid: string,
  customData?: Partial<CreateTimerDTO>,
) => {
  if (!sessionid) {
    throw new Error("Session ID is required to initialize the timer.");
  }

  const timerSettings: CreateTimerDTO = {
    sessionid,
    type: customData?.type ?? TimerType.POMODORO,
    durationminutes: customData?.durationminutes ?? 25,
    breakminutes: customData?.breakminutes ?? 5,
    longbreakminutes: customData?.longbreakminutes ?? 15,
    pomodoroscycle: customData?.pomodoroscycle ?? 4,
    isrunning: customData?.isrunning ?? false,
    remainingseconds:
      customData?.remainingseconds ??
      (customData?.durationminutes ? customData.durationminutes * 60 : 25 * 60),
  };

  return await TimerRepository.create(timerSettings);
};

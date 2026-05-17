import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";
import { TimerType } from "../../entities/timer.js";
import type { CreateTimerDTO } from "../../interfaces/dtos/Timer.dto.js";

export const CreateTimer = async (
  sessionid: string,
  customData?: Partial<CreateTimerDTO>,
) => {
  if (!sessionid) {
    throw new Error("Session ID is required to initialize the timer.");
  }

  const type = customData?.type ?? TimerType.POMODORO;
  const durationminutes = customData?.durationminutes ?? 25;
  const remainingseconds =
    customData?.remainingseconds ?? durationminutes * 60;

  const baseSettings = {
    sessionid,
    type,
    durationminutes,
    remainingseconds,
    isrunning: false,
    starttime: null,
    endtime: null,
  };

  if (type === TimerType.POMODORO) {
    return await TimerRepository.create({
      ...baseSettings,
      breakminutes: customData?.breakminutes ?? 5,
      longbreakminutes: customData?.longbreakminutes ?? 15,
      pomodorocycles: customData?.pomodorocycles ?? 4,  
    });
  }

  return await TimerRepository.create({
    ...baseSettings,
    breakminutes: null,
    longbreakminutes: null,
    pomodorocycles: null,   
  });
};
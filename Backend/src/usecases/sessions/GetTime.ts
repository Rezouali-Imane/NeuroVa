import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";

export const GetTimersBySession = async (sessionid: string) => {
    if (!sessionid) {
        throw new Error("Session ID is required to fetch timers.");
    }

    const timers = await TimerRepository.findManyBySession(sessionid);

    return {
        success: true,
        data: timers
    }
    
};


export const GetTimer = async (timerid: string) => {
  const timer = await TimerRepository.findById(timerid);
  if (!timer) throw new Error("Timer not found");
  return timer;
};

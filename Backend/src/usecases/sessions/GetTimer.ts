import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";

export const GetTimer = async (sessionid: string) => {
    const timer = await TimerRepository.findBySessionId(sessionid);

    if (!timer) {
        throw new Error("Timer not found for this session");
    }

    return timer;
};
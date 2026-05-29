import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";

export const GetTimer = async (sessionid: string) => {
    const timers = await TimerRepository.findManyBySession(sessionid);

    if (!timers || timers.length === 0) {
        throw new Error("Timer not found for this session");
    }

    // Return the first timer (legacy behavior expects a single timer)
    return timers[0];
};
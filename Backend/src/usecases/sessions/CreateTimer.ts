// CreatTimer.ts
import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";
import { TimerType } from "../../entities/Timer.js";
import type { CreateTimerDTO } from "../../interfaces/dtos/Timer.dto.js";

export const CreateTimer = async (sessionid: string) => {
    if (!sessionid) {
        throw new Error("Session ID is required to initialize the timer.");
    }
 // Initializes a timer specifically as a POMODORO by default.
    const defaultTimer: CreateTimerDTO = {
        sessionid,
        type: TimerType.POMODORO,
        durationminutes: 25,
        breakminutes: 5,
        longbreakminutes: 15,
        pomodoroscycle: 4,
        isrunning: false,
        remainingseconds: 25 * 60
    };

    return await TimerRepository.create(defaultTimer);
};
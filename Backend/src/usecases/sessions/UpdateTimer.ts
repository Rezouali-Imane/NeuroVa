import { TimerRepository } from "../../interfaces/repositories/TimerRepository.js";
import { TimerType } from "../../entities/timer.js";

export const UpdateTimer = async (sessionid: string, data: any) => {
    
    const timer = await TimerRepository.findBySessionId(sessionid);
    if (!timer) throw new Error("Timer not found");

    if (timer.type === TimerType.POMODORO && data.durationminutes !== undefined) {
        
        if (data.durationminutes === timer.durationminutes) {
            // focus time
            data.remainingseconds = timer.durationminutes * 60;
        } 
        else if (data.durationminutes === timer.breakminutes) {
            // short break time
            data.remainingseconds = timer.breakminutes * 60;
        } 
        else if (data.durationminutes === timer.longbreakminutes) {
           // long break time
            data.remainingseconds = timer.longbreakminutes * 60;
        } 

        data.isrunning = false;
        data.endtime = null;
    }
        
 
    if (data.isrunning !== undefined) {
        if (data.isrunning === true && !timer.isrunning) {
            // Start || resume
            data.starttime = new Date();
            data.endtime = null;
        } else if (data.isrunning === false && timer.isrunning) {
            // Pause
            data.endtime = new Date();
        }
    }

    return await TimerRepository.update(sessionid, data);
};
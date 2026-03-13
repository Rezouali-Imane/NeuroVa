import { TimerType } from "../../entities/timer.js";

export interface CreateTimerDTO {
    sessionid: string;
    type: TimerType;
    durationminutes: number;
    breakminutes: number;
    longbreakminutes: number;
    pomodoroscycle: number;
    isrunning: boolean;
    remainingseconds: number;
}

export interface UpdateTimerDTO {
    type?: TimerType;
    durationminutes?: number; 
    breakminutes?: number;    
    longbreakminutes?: number; 
    pomodoroscycle?: number;
    isrunning?: boolean;
    remainingseconds?: number;
    starttime?: Date | null;
    endtime?: Date | null;
}
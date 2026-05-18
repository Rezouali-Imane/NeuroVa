import { TimerType } from "../../entities/timer.js";

export interface CreateTimerDTO {
  sessionid: string;
  type: TimerType;
  durationminutes: number;
  breakminutes?: number | null;
  longbreakminutes?: number | null;
  pomodorocycles?: number | null; 
  isrunning: boolean;
  remainingseconds: number;
  starttime?: Date | null;
  endtime?: Date | null;
}

export interface UpdateTimerDTO {
    type?: TimerType;
    durationminutes?: number; 
    breakminutes?: number;    
    longbreakminutes?: number; 
    pomodorocycles?: number;
    isrunning?: boolean;
    remainingseconds?: number;
    starttime?: Date | null;
    endtime?: Date | null;
}

export interface DeleteTimerDTO {
    timerid: string;
}
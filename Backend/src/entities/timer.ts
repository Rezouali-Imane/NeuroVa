export enum TimerType {
    CHRONOMETER = "CHRONOMETER",
    COUNTDOWN = "COUNTDOWN",
    POMODORO = "POMODORO"
}

export class Timer {
    constructor(
        public readonly timerid: string,
        public readonly sessionid: string,
        public type: TimerType,
        public durationminutes: number,
        public breakminutes: number,
        public longbreakminutes: number,
        public pomodorocycles: number,
        public isrunning: boolean,
        public remainingseconds: number,
        public starttime?: Date | null,
        public endtime?: Date | null
    ) {}
}
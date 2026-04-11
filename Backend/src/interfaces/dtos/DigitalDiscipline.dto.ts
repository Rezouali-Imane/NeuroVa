export type ContentFilterLevel = 'NORMAL' | 'SFW_STRICT';

export interface UpdateDigitalDisciplineSettingsDTO {
  filterlevel?: ContentFilterLevel;
  dailyfreeminutes?: number;
  customblockingenabled?: boolean;
  faithmodeenabled?: boolean;
}

export interface CreateBlockedAppDTO {
  appname: string;
}

export interface CreateBlockedWebsiteDTO {
  domain: string;
}

export interface CreateUsageLimitDTO {
  appname: string;
  packagename?: string;
  dailylimitminutes: number;
  isactive?: boolean;
}

export interface CreateUsageLogDTO {
  appname: string;
  packagename?: string;
  usageminutes: number;
  wasblocked?: boolean;
  logdate?: Date;
}

export interface CreateDisciplineAlertDTO {
  appname?: string;
  identifier?: string;
  alerttype: string;
  message: string;
  isread?: boolean;
}

export interface UpdateDisciplineScoreDTO {
  score: number;
  violationcount?: number;
  streak?: number;
  scoredate?: Date;
}

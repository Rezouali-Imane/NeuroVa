export interface ConnectCalendarDTO {
  userid: string;
 authcode: string;
}

export interface SaveTokenDTO {
  userid: string;
  accesstoken: string;
  refreshtoken: string;
  expiresat: Date;
}

export interface DisconnectCalendarDTO {
  userid: string;
}
export interface refreshAccessTokenDTO {
  userid: string;
  refreshtoken: string;
}
export interface UpdateaccessTokenDTO {
  userid: string;
  accesstoken: string;
  expiresat: Date;
}

export interface SyncTaskDTO {
  taskid: string;
  userid: string;
}

export interface SaveGoogleEventDTO {
  taskid: string;
  googleeventid: string;
}
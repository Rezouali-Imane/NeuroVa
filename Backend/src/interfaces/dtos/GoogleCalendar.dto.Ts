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


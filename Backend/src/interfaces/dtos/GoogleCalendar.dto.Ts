export interface ConnectCalendarDTO {
  userid: string;
  accesstoken: string;
  refreshtoken: string;
  expiresat: Date;
}

export interface DisconnectCalendarDTO {
  userid: string;
}


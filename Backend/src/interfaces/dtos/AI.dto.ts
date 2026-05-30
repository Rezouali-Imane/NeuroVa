export interface SendMessageDTO {
  userid: string;
  content: string;
  major?: string;
  university?: string;
  year?: string;
  faithmode?: boolean;
  city?: string;
  directchat?: boolean;
}

export interface SendImageMessageDTO {
  userid: string;
  prompt?: string;
  imageDataUrl: string;
  directchat?: boolean;
  faithmode?: boolean;
}

export interface SendVoiceMessageDTO {
  userid: string;
  transcript: string;
  promptPrefix?: string;
  directchat?: boolean;
  faithmode?: boolean;
}

export interface GenerateStudyPlanDTO {
  userid: string;
  faithmode?: boolean;
  city?: string;
  country?: string;
}

export interface AnalyzeWeaknessDTO {
  userid: string;
}

export interface UploadDocumentDTO {
  userid: string;
  major?: string;
  subject?: string;
  filename: string;
  fileBuffer: Buffer;
  mimetype: string;
}

export interface UpdateMemoryDTO {
  userid: string;
  key: string;
  value: string;
}

export interface ScheduleFocusSessionDTO {
  userid: string;
  taskid?: string;
  durationMinutes?: number;
  faithmode?: boolean;
  city?: string;
  country?: string;
}
export interface CreateNoteDTO {
  userid: string;
  title: string;
  content?: string;
}

export interface UpdateNoteDTO {
  title?: string;
  content?: string;
}

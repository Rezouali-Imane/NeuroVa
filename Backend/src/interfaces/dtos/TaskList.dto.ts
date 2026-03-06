export interface CreateTaskListDTO {
  userid: string;
  scheduleid?: string;
  name: string;
}

export interface UpdateTaskListDTO {
  name?: string;
  scheduleid?: string;
}
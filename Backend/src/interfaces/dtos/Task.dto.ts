import { TaskStatus, TaskCategory } from '../../entities/Task.js';

export interface CreateTaskDTO {
  userid: string;
  listid: string;
  title: string;
  description?: string;
  deadline?: Date;
  priority?: number;
  category?: TaskCategory;
  syncwithgoogle?: boolean;
}

export interface UpdateTaskDTO {
  title?: string;
  description?: string;
  deadline?: Date;
  priority?: number;
  category?: TaskCategory;
  syncwithgoogle?: boolean;
  googleeventid?: string;
}

export interface UpdateTaskStatusDTO {
  status: TaskStatus;
}
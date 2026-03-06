export enum TaskStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  OVERDUE = 'OVERDUE',
}

export enum TaskCategory {
  ACADEMIC = 'ACADEMIC',
  PERSONAL = 'PERSONAL',
  WORK = 'WORK',
  HEALTH = 'HEALTH',
  OTHER = 'OTHER',
}

export interface Task {
  taskid: string;
  userid: string;
  listid: string;
  title: string;
  description?: string;
  deadline?: Date;
  priority: number;
  status: TaskStatus;
  category: TaskCategory;
  googleeventid?: string;
  syncwithgoogle: boolean;
  createdat: Date;
  updatedat: Date;
}
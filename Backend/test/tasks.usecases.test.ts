import { beforeEach, describe, expect, it, vi } from 'vitest';
import { TaskRepository } from '../src/interfaces/repositories/TaskRepository.js';
import { TaskListRepository } from '../src/interfaces/repositories/TaskListRepository.js';
import { CreateTask } from '../src/usecases/tasks/CreateTask.js';
import { DeleteTask } from '../src/usecases/tasks/DeleteTask.js';
import { GetTaskById } from '../src/usecases/tasks/GetTaskById.js';
import { GetTasks } from '../src/usecases/tasks/GetTasks.js';
import { UpdateTask } from '../src/usecases/tasks/UpdateTask.js';
import { UpdateTaskStatus } from '../src/usecases/tasks/UpdateTaskStatus.js';
import { CreateTaskList } from '../src/usecases/tasks/CreateTaskList.js';
import { DeleteTaskList } from '../src/usecases/tasks/DeleteTaskList.js';
import { GetTaskList } from '../src/usecases/tasks/GetTaskList.js';
import { UpdateTaskList } from '../src/usecases/tasks/UpdateTaskList.js';

describe('task usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('CreateTask validates required fields', async () => {
    await expect(CreateTask({ userid: 'usr1', listid: 'lst1', title: '   ' })).rejects.toThrow('Task title is required');
    await expect(CreateTask({ userid: '', listid: 'lst1', title: 'Task' })).rejects.toThrow('User ID is required');
    await expect(CreateTask({ userid: 'usr1', listid: '', title: 'Task' })).rejects.toThrow('Task list ID is required');
  });

  it('CreateTask delegates to repository', async () => {
    const payload = { userid: 'usr1', listid: 'lst1', title: 'Task' };
    const created = { taskid: 'tsk1', ...payload };
    vi.spyOn(TaskRepository, 'create').mockResolvedValue(created as any);
    await expect(CreateTask(payload as any)).resolves.toEqual(created);
  });

  it('GetTasks validates user id and returns repository data', async () => {
    await expect(GetTasks('')).rejects.toThrow('User ID is required');
    vi.spyOn(TaskRepository, 'findAllByUser').mockResolvedValue([{ taskid: 'tsk1' }] as any);
    await expect(GetTasks('usr1')).resolves.toEqual([{ taskid: 'tsk1' }]);
  });

  it('GetTaskById throws when task is missing', async () => {
    vi.spyOn(TaskRepository, 'findById').mockResolvedValue(null as any);
    await expect(GetTaskById('tsk1')).rejects.toThrow('Task not found');
  });

  it('GetTaskById returns task when present', async () => {
    const task = { taskid: 'tsk1', title: 'Task' };
    vi.spyOn(TaskRepository, 'findById').mockResolvedValue(task as any);
    await expect(GetTaskById('tsk1')).resolves.toEqual(task);
  });

  it('UpdateTask checks existence before updating', async () => {
    vi.spyOn(TaskRepository, 'findById').mockResolvedValue(null as any);
    await expect(UpdateTask('tsk1', { title: 'Updated' })).rejects.toThrow('Task not found');

    vi.spyOn(TaskRepository, 'findById').mockResolvedValue({ taskid: 'tsk1' } as any);
    const updateSpy = vi.spyOn(TaskRepository, 'update').mockResolvedValue({ taskid: 'tsk1', title: 'Updated' } as any);
    await expect(UpdateTask('tsk1', { title: 'Updated' })).resolves.toEqual({ taskid: 'tsk1', title: 'Updated' });
    expect(updateSpy).toHaveBeenCalledWith('tsk1', { title: 'Updated' });
  });

  it('UpdateTaskStatus checks existence before updating status', async () => {
    vi.spyOn(TaskRepository, 'findById').mockResolvedValue(null as any);
    await expect(UpdateTaskStatus('tsk1', { status: 'COMPLETED' as any })).rejects.toThrow('Task not found');

    vi.spyOn(TaskRepository, 'findById').mockResolvedValue({ taskid: 'tsk1' } as any);
    const updateSpy = vi.spyOn(TaskRepository, 'updateStatus').mockResolvedValue({ taskid: 'tsk1', status: 'COMPLETED' } as any);
    await expect(UpdateTaskStatus('tsk1', { status: 'COMPLETED' as any })).resolves.toEqual({ taskid: 'tsk1', status: 'COMPLETED' });
    expect(updateSpy).toHaveBeenCalledWith('tsk1', 'COMPLETED');
  });

  it('DeleteTask checks existence before deleting', async () => {
    vi.spyOn(TaskRepository, 'findById').mockResolvedValue(null as any);
    await expect(DeleteTask('tsk1')).rejects.toThrow('Task not found');

    vi.spyOn(TaskRepository, 'findById').mockResolvedValue({ taskid: 'tsk1' } as any);
    const deleteSpy = vi.spyOn(TaskRepository, 'delete').mockResolvedValue({ taskid: 'tsk1' } as any);
    await expect(DeleteTask('tsk1')).resolves.toEqual({ taskid: 'tsk1' });
    expect(deleteSpy).toHaveBeenCalledWith('tsk1');
  });

  it('CreateTaskList validates required fields', async () => {
    await expect(CreateTaskList({ userid: 'usr1', name: '   ' })).rejects.toThrow('Task list name is required');
    await expect(CreateTaskList({ userid: '', name: 'General' })).rejects.toThrow('User ID is required');
  });

  it('CreateTaskList delegates to repository', async () => {
    const payload = { userid: 'usr1', name: 'General' };
    const created = { listid: 'lst1', ...payload };
    vi.spyOn(TaskListRepository, 'create').mockResolvedValue(created as any);
    await expect(CreateTaskList(payload)).resolves.toEqual(created);
  });

  it('GetTaskList validates user id and returns repository data', async () => {
    await expect(GetTaskList('')).rejects.toThrow('User ID is required');
    vi.spyOn(TaskListRepository, 'findAllByUser').mockResolvedValue([{ listid: 'lst1' }] as any);
    await expect(GetTaskList('usr1')).resolves.toEqual([{ listid: 'lst1' }]);
  });

  it('UpdateTaskList checks existence before updating', async () => {
    vi.spyOn(TaskListRepository, 'findById').mockResolvedValue(null as any);
    await expect(UpdateTaskList('lst1', { name: 'Renamed' })).rejects.toThrow('Task list not found');

    vi.spyOn(TaskListRepository, 'findById').mockResolvedValue({ listid: 'lst1' } as any);
    const updateSpy = vi.spyOn(TaskListRepository, 'update').mockResolvedValue({ listid: 'lst1', name: 'Renamed' } as any);
    await expect(UpdateTaskList('lst1', { name: 'Renamed' })).resolves.toEqual({ listid: 'lst1', name: 'Renamed' });
    expect(updateSpy).toHaveBeenCalledWith('lst1', { name: 'Renamed' });
  });

  it('DeleteTaskList checks existence before deleting', async () => {
    vi.spyOn(TaskListRepository, 'findById').mockResolvedValue(null as any);
    await expect(DeleteTaskList('lst1')).rejects.toThrow('Task list not found');

    vi.spyOn(TaskListRepository, 'findById').mockResolvedValue({ listid: 'lst1' } as any);
    const deleteSpy = vi.spyOn(TaskListRepository, 'delete').mockResolvedValue({ listid: 'lst1' } as any);
    await expect(DeleteTaskList('lst1')).resolves.toEqual({ listid: 'lst1' });
    expect(deleteSpy).toHaveBeenCalledWith('lst1');
  });
});
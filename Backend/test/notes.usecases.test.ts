import { beforeEach, describe, expect, it, vi } from 'vitest';
import { NoteRepository } from '../src/interfaces/repositories/NoteRepository.js';
import { CreateNote } from '../src/usecases/Notes/CreateNote.js';
import { DeleteNote } from '../src/usecases/Notes/DeleteNote.js';
import { GetNoteById } from '../src/usecases/Notes/GetNoteById.js';
import { GetNotes } from '../src/usecases/Notes/GetNotes.js';
import { UpdateNote } from '../src/usecases/Notes/UpdateNote.js';

describe('note usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('CreateNote validates title and user id', async () => {
    await expect(CreateNote({ userid: 'usr1', title: '   ' })).rejects.toThrow('Note title is required');
    await expect(CreateNote({ userid: '', title: 'Note' })).rejects.toThrow('User ID is required');
  });

  it('CreateNote delegates to repository', async () => {
    const payload = { userid: 'usr1', title: 'Note' };
    const created = { noteid: 'nte1', ...payload };
    vi.spyOn(NoteRepository, 'create').mockResolvedValue(created as any);
    await expect(CreateNote(payload as any)).resolves.toEqual(created);
  });

  it('GetNotes validates user id and returns repository data', async () => {
    await expect(GetNotes('')).rejects.toThrow('User ID is required');
    vi.spyOn(NoteRepository, 'findAllByUser').mockResolvedValue([{ noteid: 'nte1' }] as any);
    await expect(GetNotes('usr1')).resolves.toEqual([{ noteid: 'nte1' }]);
  });

  it('GetNoteById throws when note is missing', async () => {
    vi.spyOn(NoteRepository, 'findById').mockResolvedValue(null as any);
    await expect(GetNoteById('nte1')).rejects.toThrow('Note not found');
  });

  it('GetNoteById returns note when present', async () => {
    const note = { noteid: 'nte1', title: 'Note' };
    vi.spyOn(NoteRepository, 'findById').mockResolvedValue(note as any);
    await expect(GetNoteById('nte1')).resolves.toEqual(note);
  });

  it('UpdateNote checks existence before updating', async () => {
    vi.spyOn(NoteRepository, 'findById').mockResolvedValue(null as any);
    await expect(UpdateNote('nte1', { title: 'Updated' })).rejects.toThrow('Note not found');

    vi.spyOn(NoteRepository, 'findById').mockResolvedValue({ noteid: 'nte1' } as any);
    const updateSpy = vi.spyOn(NoteRepository, 'update').mockResolvedValue({ noteid: 'nte1', title: 'Updated' } as any);
    await expect(UpdateNote('nte1', { title: 'Updated' })).resolves.toEqual({ noteid: 'nte1', title: 'Updated' });
    expect(updateSpy).toHaveBeenCalledWith('nte1', { title: 'Updated' });
  });

  it('DeleteNote checks existence before deleting', async () => {
    vi.spyOn(NoteRepository, 'findById').mockResolvedValue(null as any);
    await expect(DeleteNote('nte1')).rejects.toThrow('Note not found');

    vi.spyOn(NoteRepository, 'findById').mockResolvedValue({ noteid: 'nte1' } as any);
    const deleteSpy = vi.spyOn(NoteRepository, 'delete').mockResolvedValue({ noteid: 'nte1' } as any);
    await expect(DeleteNote('nte1')).resolves.toEqual({ noteid: 'nte1' });
    expect(deleteSpy).toHaveBeenCalledWith('nte1');
  });
});
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { FocusSessionRepository } from '../src/interfaces/repositories/FocusSessionRepository.js';
import { TimerRepository } from '../src/interfaces/repositories/TimerRepository.js';
import { FocusAudioRepository } from '../src/interfaces/repositories/FocusAudioSettingsRepository.js';
import { SessionStatus } from '../src/entities/FocusSession.js';
import { TimerType } from '../src/entities/timer.js';
import { CreateSession } from '../src/usecases/sessions/CreateSession.js';
import { DeleteSession } from '../src/usecases/sessions/DeleteSession.js';
import { EndSession } from '../src/usecases/sessions/EndSession.js';
import { GetSessionById } from '../src/usecases/sessions/GetSessionById.js';
import { GetSessions } from '../src/usecases/sessions/GetSession.js';
import { StartSession } from '../src/usecases/sessions/StartSession.js';
import { CreateTimer } from '../src/usecases/sessions/CreateTimer.js';
import { DeleteTimer } from '../src/usecases/sessions/DeleteTimer.js';
import { GetTimer as GetTimerBySession } from '../src/usecases/sessions/GetTimer.js';
import { GetTimer, GetTimersBySession } from '../src/usecases/sessions/GetTime.js';
import { UpdateTimer } from '../src/usecases/sessions/UpdateTimer.js';
import { CreateFocusAudio } from '../src/usecases/sessions/CreateAudioSettings.js';
import { DeleteAudioSettings } from '../src/usecases/sessions/DeleteAudio.js';
import { GetAudioById, GetAudioBySession } from '../src/usecases/sessions/GetAudioSetting.js';
import { UpdateAudioSettings } from '../src/usecases/sessions/UpdateAudioSettings.js';
import { CreateAmbientSound } from '../src/usecases/sessions/CreateAmbientSound.js';
import { UpdateAmbientSound } from '../src/usecases/sessions/UpdateAmbientSound.js';
import { RemoveAmbientSound } from '../src/usecases/sessions/DeleteAmbientSound.js';
import { GetAmbientSoundById, GetAmbientSoundsBySettings } from '../src/usecases/sessions/GetAmbientSound.js';

describe('session usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('CreateSession validates required fields', async () => {
    const start = new Date('2026-01-01T10:00:00Z');
    const end = new Date('2026-01-01T11:00:00Z');
    await expect(CreateSession({ userid: '', starttime: start, endtime: end } as any)).rejects.toThrow('User ID is required');
    await expect(CreateSession({ userid: 'usr1', endtime: end } as any)).rejects.toThrow('Start time is required');
    await expect(CreateSession({ userid: 'usr1', starttime: start } as any)).rejects.toThrow('End time is required');
    await expect(CreateSession({ userid: 'usr1', starttime: end, endtime: start } as any)).rejects.toThrow('End time must be after start time');
    await expect(CreateSession({ userid: 'usr1', starttime: start, endtime: end, allowbreakminutes: -1 } as any)).rejects.toThrow('Break minutes cannot be negative');
  });

  it('CreateSession applies defaults and delegates to repository', async () => {
    const start = new Date('2026-01-01T10:00:00Z');
    const end = new Date('2026-01-01T11:00:00Z');
    const createSpy = vi.spyOn(FocusSessionRepository, 'create').mockResolvedValue({ sessionid: 'ssn1' } as any);
    await CreateSession({ userid: 'usr1', starttime: start, endtime: end } as any);
    expect(createSpy).toHaveBeenCalledWith(expect.objectContaining({ userid: 'usr1', allowbreakminutes: 0, focusscore: 0, status: SessionStatus.SCHEDULED, scheduleid: null, roomid: null }));
  });

  it('GetSessions returns repository data', async () => {
    vi.spyOn(FocusSessionRepository, 'findAllByUser').mockResolvedValue([{ sessionid: 'ssn1' }] as any);
    await expect(GetSessions('usr1')).resolves.toEqual([{ sessionid: 'ssn1' }]);
  });

  it('GetSessionById and DeleteSession require an existing session', async () => {
    vi.spyOn(FocusSessionRepository, 'findById').mockResolvedValue(null as any);
    await expect(GetSessionById('ssn1')).rejects.toThrow('Session not found');
    await expect(DeleteSession('ssn1')).rejects.toThrow('Session not found');
  });

  it('GetSessionById and DeleteSession use the repository when session exists', async () => {
    vi.spyOn(FocusSessionRepository, 'findById').mockResolvedValue({ sessionid: 'ssn1' } as any);
    vi.spyOn(FocusSessionRepository, 'delete').mockResolvedValue({ sessionid: 'ssn1' } as any);
    await expect(GetSessionById('ssn1')).resolves.toEqual({ sessionid: 'ssn1' });
    await expect(DeleteSession('ssn1')).resolves.toEqual({ sessionid: 'ssn1' });
  });

  it('StartSession and EndSession update session state', async () => {
    vi.spyOn(FocusSessionRepository, 'findById').mockResolvedValue({ sessionid: 'ssn1' } as any);
    const updateSpy = vi.spyOn(FocusSessionRepository, 'update').mockResolvedValue({ sessionid: 'ssn1' } as any);
    await StartSession('ssn1');
    expect(updateSpy).toHaveBeenCalledWith('ssn1', expect.objectContaining({ status: SessionStatus.ACTIVE, starttime: expect.any(Date) }));
    await EndSession('ssn1');
    expect(updateSpy).toHaveBeenCalledWith('ssn1', expect.objectContaining({ status: SessionStatus.COMPLETED, endtime: expect.any(Date) }));
  });

  it('CreateTimer validates session id and builds defaults', async () => {
    await expect(CreateTimer('')).rejects.toThrow('Session ID is required to initialize the timer.');
    const createSpy = vi.spyOn(TimerRepository, 'create').mockResolvedValue({ timerid: 'tmr1' } as any);
    await CreateTimer('ssn1');
    expect(createSpy).toHaveBeenCalledWith(expect.objectContaining({ sessionid: 'ssn1', type: TimerType.POMODORO, durationminutes: 25, remainingseconds: 1500, isrunning: false }));
  });

  it('GetTimer usecases return or reject correctly', async () => {
    vi.spyOn(TimerRepository, 'findBySessionId').mockResolvedValue(null as any);
    await expect(GetTimerBySession('ssn1')).rejects.toThrow('Timer not found for this session');

    vi.spyOn(TimerRepository, 'findById').mockResolvedValue(null as any);
    await expect(GetTimer('tmr1')).rejects.toThrow('Timer not found');

    vi.spyOn(TimerRepository, 'findBySessionId').mockResolvedValue({ timerid: 'tmr1' } as any);
    vi.spyOn(TimerRepository, 'findById').mockResolvedValue({ timerid: 'tmr1' } as any);
    vi.spyOn(TimerRepository, 'findManyBySession').mockResolvedValue([{ timerid: 'tmr1' }] as any);
    await expect(GetTimerBySession('ssn1')).resolves.toEqual({ timerid: 'tmr1' });
    await expect(GetTimersBySession('ssn1')).resolves.toEqual({ success: true, data: [{ timerid: 'tmr1' }] });
    await expect(GetTimer('tmr1')).resolves.toEqual({ timerid: 'tmr1' });
  });

  it('DeleteTimer validates id and existence', async () => {
    await expect(DeleteTimer({ timerid: '' } as any)).rejects.toThrow('Timer ID is required.');
    vi.spyOn(TimerRepository, 'findById').mockResolvedValue(null as any);
    await expect(DeleteTimer({ timerid: 'tmr1' } as any)).rejects.toThrow('Timer not found.');
    vi.spyOn(TimerRepository, 'findById').mockResolvedValue({ timerid: 'tmr1' } as any);
    vi.spyOn(TimerRepository, 'delete').mockResolvedValue({ timerid: 'tmr1' } as any);
    await expect(DeleteTimer({ timerid: 'tmr1' } as any)).resolves.toEqual({ timerid: 'tmr1' });
  });

  it('UpdateTimer adjusts remaining seconds and running timestamps', async () => {
    vi.spyOn(TimerRepository, 'findById').mockResolvedValue({
      timerid: 'tmr1',
      type: TimerType.POMODORO,
      durationminutes: 25,
      breakminutes: 5,
      longbreakminutes: 15,
      isrunning: false,
    } as any);
    const updateSpy = vi.spyOn(TimerRepository, 'update').mockResolvedValue({ timerid: 'tmr1' } as any);
    await UpdateTimer('tmr1', { durationminutes: 25, isrunning: true });
    expect(updateSpy).toHaveBeenCalledWith('tmr1', expect.objectContaining({ durationminutes: 25, remainingseconds: 1500, isrunning: false, endtime: null }));
  });

  it('CreateFocusAudio validates session id and delegates defaults', async () => {
    await expect(CreateFocusAudio('')).rejects.toThrow('A Session ID is required to initialize audio settings.');
    const createSpy = vi.spyOn(FocusAudioRepository, 'create').mockResolvedValue({ settingsid: 'fas1' } as any);
    await CreateFocusAudio('ssn1');
    expect(createSpy).toHaveBeenCalledWith({ sessionid: 'ssn1', volumelevel: 1, mixambientsounds: false, sounds: [] });
  });

  it('GetAudio usecases validate ids and delegate correctly', async () => {
    await expect(GetAudioById('')).rejects.toThrow('Settings ID is required.');
    vi.spyOn(FocusAudioRepository, 'findById').mockResolvedValue(null as any);
    await expect(GetAudioById('fas1')).rejects.toThrow('Audio settings not found.');

    vi.spyOn(FocusAudioRepository, 'findById').mockResolvedValue({ settingsid: 'fas1' } as any);
    vi.spyOn(FocusAudioRepository, 'findManyBySession').mockResolvedValue([{ settingsid: 'fas1' }] as any);
    await expect(GetAudioById('fas1')).resolves.toEqual({ settingsid: 'fas1' });
    await expect(GetAudioBySession('ssn1')).resolves.toEqual([{ settingsid: 'fas1' }]);
  });

  it('UpdateAudioSettings validates id and clamps volume', async () => {
    await expect(UpdateAudioSettings('', { volumelevel: 2 } as any)).rejects.toThrow('Settings ID is required.');
    vi.spyOn(FocusAudioRepository, 'updateSettings').mockResolvedValue({ settingsid: 'fas1', volumelevel: 1 } as any);
    await expect(UpdateAudioSettings('fas1', { volumelevel: 2 } as any)).resolves.toEqual({ success: true, message: 'Settings updated.', data: { settingsid: 'fas1', volumelevel: 1 } });
    expect(FocusAudioRepository.updateSettings).toHaveBeenCalledWith('fas1', { volumelevel: 1 });
  });

  it('DeleteAudioSettings validates id and delegates to repository', async () => {
    await expect(DeleteAudioSettings({ settingsid: '' } as any)).rejects.toThrow('Settings ID is required.');
    vi.spyOn(FocusAudioRepository, 'delete').mockResolvedValue({ settingsid: 'fas1' } as any);
    await expect(DeleteAudioSettings({ settingsid: 'fas1' } as any)).resolves.toEqual({ settingsid: 'fas1' });
  });

  it('ambient sound usecases validate and return expected shapes', async () => {
    await expect(CreateAmbientSound('', { name: 'Rain' } as any)).rejects.toThrow('Settings ID is required.');
    await expect(UpdateAmbientSound('', { name: 'Rain' } as any)).rejects.toThrow('Sound ID is required for update.');
    await expect(RemoveAmbientSound({ soundid: '' } as any)).rejects.toThrow('Sound ID is required.');
    await expect(GetAmbientSoundById('')).rejects.toThrow('Sound ID is required.');
    await expect(GetAmbientSoundsBySettings('')).rejects.toThrow('Settings ID is required.');

    vi.spyOn(FocusAudioRepository, 'createAmbientSound').mockResolvedValue({ soundid: 'snd1', name: 'Rain' } as any);
    vi.spyOn(FocusAudioRepository, 'updateAmbientSound').mockResolvedValue({ soundid: 'snd1', name: 'Rain+' } as any);
    vi.spyOn(FocusAudioRepository, 'deleteAmbientSound').mockResolvedValue({ soundid: 'snd1' } as any);
    vi.spyOn(FocusAudioRepository, 'findAmbientSoundById').mockResolvedValue({ soundid: 'snd1' } as any);
    vi.spyOn(FocusAudioRepository, 'findSoundsBySettings').mockResolvedValue([{ soundid: 'snd1' }] as any);

    await expect(CreateAmbientSound('fas1', { name: 'Rain' } as any)).resolves.toEqual({ success: true, message: 'Sound "Rain" added.', data: { soundid: 'snd1', name: 'Rain' } });
    await expect(UpdateAmbientSound('snd1', { name: 'Rain' } as any)).resolves.toEqual({ success: true, message: 'Sound "Rain+" modified.', data: { soundid: 'snd1', name: 'Rain+' } });
    await expect(RemoveAmbientSound({ soundid: 'snd1' } as any)).resolves.toEqual({ soundid: 'snd1' });
    await expect(GetAmbientSoundById('snd1')).resolves.toEqual({ soundid: 'snd1' });
    await expect(GetAmbientSoundsBySettings('fas1')).resolves.toEqual([{ soundid: 'snd1' }]);
  });
});
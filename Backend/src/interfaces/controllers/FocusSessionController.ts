import type { Request, Response } from "express";
import { CreateSession } from "../../usecases/sessions/CreateSession.js";
import { StartSession } from "../../usecases/sessions/StartSession.js";
import { EndSession } from "../../usecases/sessions/EndSession.js";
import { GetSessions } from "../../usecases/sessions/GetSession.js";
import { GetSessionById } from "../../usecases/sessions/GetSessionById.js";
import { DeleteSession } from "../../usecases/sessions/DeleteSession.js";

import { CreateTimer } from "../../usecases/sessions/CreateTimer.js";
import { UpdateTimer } from "../../usecases/sessions/UpdateTimer.js";
import { GetTimer, GetTimersBySession } from "../../usecases/sessions/GetTime.js";
import { DeleteTimer } from "../../usecases/sessions/DeleteTimer.js";

import { CreateFocusAudio } from "../../usecases/sessions/CreateAudioSettings.js";
import { UpdateAudioSettings } from "../../usecases/sessions/UpdateAudioSettings.js";
import { GetAudioById, GetAudioBySession } from "../../usecases/sessions/GetAudioSetting.js";
import { DeleteAudioSettings } from "../../usecases/sessions/DeleteAudio.js";

import { CreateAmbientSound } from "../../usecases/sessions/CreateAmbientSound.js";
import { UpdateAmbientSound } from "../../usecases/sessions/UpdateAmbientSound.js";
import { GetAmbientSoundsBySettings, GetAmbientSoundById } from "../../usecases/sessions/GetAmbientSound.js";
import { RemoveAmbientSound } from "../../usecases/sessions/DeleteAmbientSound.js";

export const FocusSessionController = {
  // Session lifecycle endpoints.
  async create(req: Request, res: Response) {
    try {
      const session = await CreateSession(req.body);
      await CreateTimer(session.sessionid, req.body.timerSettings);
      await CreateFocusAudio(session.sessionid);
      res.status(201).json({ success: true, data: session });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async delete(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      await DeleteSession(sessionid);
      res.status(200).json({ success: true, message: "Session deleted" });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAll(req: Request, res: Response) {
    try {
      const userid = req.params["userid"] as string;
      const sessions = await GetSessions(userid);
      res.status(200).json({ success: true, data: sessions });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const session = await GetSessionById(sessionid);
      res.status(200).json({ success: true, data: session });
    } catch (error: any) {
      res.status(404).json({ success: false, message: error.message });
    }
  },

  async start(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const session = await StartSession(sessionid);
      res.status(200).json({ success: true, data: session });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async end(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const session = await EndSession(sessionid);
      res.status(200).json({ success: true, data: session });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Timer endpoints.

  async addTimer(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const timer = await CreateTimer(sessionid, req.body);
      res.status(201).json({ success: true, data: timer });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async removeTimer(req: Request, res: Response) {
    try {
      const timerid = req.params["timerid"] as string;
      await DeleteTimer({ timerid });
      res.status(200).json({ success: true, message: "Timer deleted successfully." });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getTimersBySession(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const result = await GetTimersBySession(sessionid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getTimer(req: Request, res: Response) {
    try {
      const timerid = req.params["timerid"] as string;
      const result = await GetTimer(timerid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateTimer(req: Request, res: Response) {
    try {
      const timerid = req.params["timerid"] as string;
      const result = await UpdateTimer(timerid, req.body);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Audio settings endpoints.

  async addAudio(req: Request, res: Response) {
    try {
      const sessionid = req.params["sessionid"] as string;
      const audio = await CreateFocusAudio(sessionid, req.body);
      res.status(201).json({ success: true, data: audio });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async removeAudio(req: Request, res: Response) {
    try {
      const settingsid = req.params["settingsid"] as string;
      await DeleteAudioSettings({ settingsid });
      res.status(200).json({ success: true, message: "Audio settings deleted successfully." });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateAudioSettings(req: Request, res: Response) {
    try {
      const settingsid = req.params["settingsid"] as string;
      const result = await UpdateAudioSettings(settingsid, req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAudioById(req: Request, res: Response) {
    try {
      const settingsid = req.params['settingsid'] as string;
      const result = await GetAudioById(settingsid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(404).json({ success: false, message: error.message });
    }
  },

  async getAudioBySession(req: Request, res: Response) {
    try {
      const sessionid = req.params['sessionid'] as string;
      const result = await GetAudioBySession(sessionid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Ambient sound endpoints.

  async getAmbientSoundsBySettings(req: Request, res: Response) {
    try {
      const settingsid = req.params['settingsid'] as string;
      const result = await GetAmbientSoundsBySettings(settingsid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getAmbientSoundById(req: Request, res: Response) {
    try {
      const soundid = req.params['soundid'] as string;
      const result = await GetAmbientSoundById(soundid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(404).json({ success: false, message: error.message });
    }
  },

  async addAmbientSound(req: Request, res: Response) {
    try {
      const settingsid = req.params["settingsid"] as string;
      const result = await CreateAmbientSound(settingsid, req.body);
      res.status(201).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateAmbientSound(req: Request, res: Response) {
    try {
      const soundid = req.params["soundid"] as string;
      const result = await UpdateAmbientSound(soundid, req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async deleteAmbientSound(req: Request, res: Response) {
    try {
      const soundid = req.params["soundid"] as string;
      const result = await RemoveAmbientSound({ soundid });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },
};
import type { Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { connectGoogleCalendar } from "../../usecases/GoogleCalendar/ConnectToGoogleCalendar.js";
import { disconnectGoogleCalendar } from "../../usecases/GoogleCalendar/DisconectGoogleClendar.js";
import { syncGoogleToTask } from "../../usecases/GoogleCalendar/SyncGoogleToTask.js";
import { syncTaskToGoogle } from "../../usecases/GoogleCalendar/SyncTaskToGoogle.js";
// import { refreshToken } from "../../usecases/GoogleCalendar/RefreshToken.js";
import { deleteGoogleEvent } from "../../usecases/GoogleCalendar/DeleteGoogleEvent.js";
import { googleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarServiceImpl.js';
import { updateCalendarEvent } from '../../usecases/GoogleCalendar/UpdateCalendarEvent.js';
import { fullSync } from '../../usecases/GoogleCalendar/FullSync.js';

export const GoogleCalendarController = {
  async ConnectGoogleCalendar(req: AuthRequest, res: Response) {
    try {
     const { userid } = (req as AuthRequest).user!;
      const { code } = req.body;
      const result = await connectGoogleCalendar({ userid, authcode: code }, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

  async DisconnectGoogleCalendar(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await disconnectGoogleCalendar({ userid });
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

  async SyncTaskToGoogle(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { taskid } = req.body;
      const result = await syncTaskToGoogle({ userid, taskid }, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

// async RefreshToken(req: AuthRequest, res: Response) {
//     try {
//         const { userid } = (req as AuthRequest).user!;
//         const { refreshtoken } = req.body;
//         const result = await refreshToken({ userid, refreshtoken }, googleCalendarService);
//         res.status(200).json({ success: true, data: result });
//     } catch (error) {
//         const message = error instanceof Error ? error.message : String(error);
//         res.status(400).json({ success: false, message });
//     }
// },

  async SyncGoogleToTask(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { eventid, listid } = req.body;
      const result = await syncGoogleToTask({ userid, eventid, listid }, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

  async DeleteGoogleEvent(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { eventid, taskid } = req.body;
      const result = await deleteGoogleEvent({ userid, eventid, taskid }, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

  async UpdateCalendarEvent(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { taskid } = req.body;
      const result = await updateCalendarEvent(userid, taskid, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },

  async FullSync(req: AuthRequest, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { listid } = req.body;
      const result = await fullSync(userid, listid, googleCalendarService);
      res.status(200).json({ success: true, data: result });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      res.status(400).json({ success: false, message });
    }
  },
};
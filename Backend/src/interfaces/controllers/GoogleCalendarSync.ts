import type { Request, Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { connectGoogleCalendar } from "../../usecases/GoogleCalendar/ConnectToGoogleCalendar.js";
import { DisconnectGoogleCalendarUseCase } from "../../usecases/GoogleCalendar/DisconectGoogleClendar.js";
import { SyncGoogleToTaskUseCase } from "../../usecases/GoogleCalendar/SyncGoogleToTask.js";
import { SyncTaskToGoogleUseCase } from "../../usecases/GoogleCalendar/SyncTaskToGoogle.js";
import { RefreshTokenUseCase } from "../../usecases/GoogleCalendar/RefreshToken.js";
import { DeleteGoogleEventUseCase } from "../../usecases/GoogleCalendar/DeleteGoogleEvent.js";
import type { GoogleCalendarService } from '../../infrastructure/GoogleCalendar/GoogleCalendarService.js';


export const GoogleCalendarController = {
    async ConnectGoogleCalendar(req: AuthRequest, res: Response) {
  try {
    const { userid } = (req as AuthRequest).user!;
    const { code } = req.body;

    const result = await connectGoogleCalendar({ userid, authcode: code }, GoogleCalendarService);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    res.status(400).json({ success: false, message });
  }
}

}
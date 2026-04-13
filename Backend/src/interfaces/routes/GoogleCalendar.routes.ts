import { GoogleCalendarController } from "../controllers/GoogleCalendarSync.js";
import { Router } from "express";

const router = Router();

router.post("/connect", GoogleCalendarController.ConnectGoogleCalendar);
router.post("/disconnect", GoogleCalendarController.DisconnectGoogleCalendar);
router.post("/sync-task-to-google", GoogleCalendarController.SyncTaskToGoogle);
router.post("/refresh-token", GoogleCalendarController.RefreshToken);
router.post("/sync-google-to-task", GoogleCalendarController.SyncGoogleToTask);
router.post("/delete-google-event", GoogleCalendarController.DeleteGoogleEvent);

export default router;
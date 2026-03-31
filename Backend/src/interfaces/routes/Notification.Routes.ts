import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController.js";

const router = Router();

// Get all notifications for user
router.get("/", NotificationController.getUserNotifications);

// Mark a notification as read
router.patch("/:id/read", NotificationController.markAsRead);

// Mark all notifications as read
router.patch("/read-all", NotificationController.markAllAsRead);

// Delete a notification
router.delete("/:id", NotificationController.deleteNotification);

// Get notification settings
router.get("/settings", NotificationController.getSettings);

// Update notification settings
router.put("/settings", NotificationController.updateSettings);

export default router;
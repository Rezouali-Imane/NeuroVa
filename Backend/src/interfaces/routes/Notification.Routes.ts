import { Router } from "express";
import { NotificationController } from "../controllers/NotificationController.js";

const router = Router();

// Create a new notification
router.post("/", NotificationController.CreateNotification);

// Delete a notification
router.delete("/:notificationid", NotificationController.DeleteNotification);

// Get notifications for a user
router.get("/user/:userid", NotificationController.getUserNotifications);

// Mark a notification as read
router.post("/:notificationid/read", NotificationController.markAsRead);

// Mark all notifications as read for a user
router.post("/user/:userid/read", NotificationController.markAllAsRead);

// get notifications Settings for a user
router.get("/user/:userid/settings", NotificationController.getNotificationSettings);

// update notifications Settings for a user
router.post("/user/:userid/settings", NotificationController.updateNotificationSettings);

// send email notifications to users
router.post("/send-email", NotificationController.sendEmailMessages);

// send push notifications to users
router.post("/send-push", NotificationController.sendPushNotification);

export default router;
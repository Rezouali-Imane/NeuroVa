import { Router } from 'express';
import { AIAssistantController, upload } from '../controllers/AIAssistantController.js';

const router = Router();

// Chat endpoints.
router.post('/message', AIAssistantController.sendMessage);
router.get('/history/:userid', AIAssistantController.getChatHistory);
router.delete('/history/:userid', AIAssistantController.clearChatHistory);

// Study planning and weakness analysis endpoints.
router.post('/study-plan/:userid', AIAssistantController.generateStudyPlan);
router.post('/weakness/:userid', AIAssistantController.analyzeWeakness);

// Student memory endpoints.
router.get('/memory/:userid', AIAssistantController.getMemory);
router.put('/memory/:userid', AIAssistantController.updateMemory);

// Knowledge base endpoints (multipart/form-data for uploads).
router.post('/knowledge', upload.single('file'), AIAssistantController.uploadDocument);
router.get('/knowledge/:userid', AIAssistantController.getKnowledgeBase);
router.delete('/knowledge/:id', AIAssistantController.deleteDocument);

// Automation endpoints.
router.post('/schedule-session/:userid', AIAssistantController.scheduleFocusSession);
router.post('/reminders/:userid', AIAssistantController.sendReminders);
router.post('/reminders', AIAssistantController.sendReminders); // Broadcast reminders for all users

export default router;
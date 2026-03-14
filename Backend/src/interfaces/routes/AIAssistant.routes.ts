import { Router } from 'express';
import { AIAssistantController, upload } from '../controllers/AIAssistantController.js';

const router = Router();

// Chat endpoints
router.post('/message', AIAssistantController.sendMessage);
router.get('/history/:userid', AIAssistantController.getChatHistory);
router.delete('/history/:userid', AIAssistantController.clearChatHistory);

// Study planning and weakness analysis
router.post('/study-plan/:userid', AIAssistantController.generateStudyPlan);
router.post('/weakness/:userid', AIAssistantController.analyzeWeakness);

// Student memory
router.get('/memory/:userid', AIAssistantController.getMemory);
router.put('/memory/:userid', AIAssistantController.updateMemory);

// Knowledge base (multipart/form-data for uploads)
router.post('/knowledge', upload.single('file'), AIAssistantController.uploadDocument);
router.get('/knowledge/:userid', AIAssistantController.getKnowledgeBase);
router.delete('/knowledge/:id', AIAssistantController.deleteDocument);

// Agent actions
router.post('/schedule-session/:userid', AIAssistantController.scheduleFocusSession);
router.post('/reminders/:userid', AIAssistantController.sendReminders);
router.post('/reminders', AIAssistantController.sendReminders); // Broadcast reminders for all users

export default router;
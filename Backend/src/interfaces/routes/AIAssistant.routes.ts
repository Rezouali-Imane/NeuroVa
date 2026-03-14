import { Router } from 'express';
import { AIAssistantController, upload } from '../controllers/AIAssistantController.js';

const router = Router();

// ── Layer 1+2+3 — Chat ────────────────────────────────────────
router.post('/message', AIAssistantController.sendMessage);
router.get('/history/:userid', AIAssistantController.getChatHistory);
router.delete('/history/:userid', AIAssistantController.clearChatHistory);

// ── Layer 2 — Smart Features ──────────────────────────────────
router.post('/study-plan/:userid', AIAssistantController.generateStudyPlan);
router.post('/weakness/:userid', AIAssistantController.analyzeWeakness);

// ── Layer 2 — Memory ──────────────────────────────────────────
router.get('/memory/:userid', AIAssistantController.getMemory);
router.put('/memory/:userid', AIAssistantController.updateMemory);

// ── Layer 3 — RAG Knowledge Base ─────────────────────────────
// ⚠️ uses multipart/form-data NOT json — set this in Postman
router.post('/knowledge', upload.single('file'), AIAssistantController.uploadDocument);
router.get('/knowledge/:userid', AIAssistantController.getKnowledgeBase);
router.delete('/knowledge/:id', AIAssistantController.deleteDocument);

// ── Layer 4 — Agentic ─────────────────────────────────────────
router.post('/schedule-session/:userid', AIAssistantController.scheduleFocusSession);
router.post('/reminders/:userid', AIAssistantController.sendReminders);
router.post('/reminders', AIAssistantController.sendReminders); // all users

export default router;
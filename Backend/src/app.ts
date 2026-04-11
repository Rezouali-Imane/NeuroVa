import express from 'express';
import cors from 'cors';
import type { Application } from 'express';
import taskRoutes from './interfaces/routes/Tasks.routes.js';
import taskListRoutes from './interfaces/routes/TaskLists.routes.js';
import authRoutes from './interfaces/routes/Auth.routes.js';
import aiRoutes from './interfaces/routes/AIAssistant.routes.js';
import focusSessionRoutes from './interfaces/routes/FocusSession.routes.js';
import noteRoutes from './interfaces/routes/Notes.routes.js';
import studyRoomRoutes from './interfaces/routes/StudyRoom.routes.js'
import digitalDisciplineRoutes from './interfaces/routes/DigitalDiscipline.routes.js';
import contentModerationRoutes from './interfaces/routes/ContentModeration.routes.js';
import { authMiddleware } from './infrastructure/middleware/authMiddleware.js';

const app: Application = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/api/tasks', authMiddleware, taskRoutes);
app.use('/api/tasklists', authMiddleware, taskListRoutes);
app.use('/api/notes', authMiddleware, noteRoutes);
app.use('/api/ai', authMiddleware, aiRoutes);
app.use('/api/focus-sessions', authMiddleware, focusSessionRoutes);
app.use('/api/studyroom', authMiddleware, studyRoomRoutes);
app.use('/api/discipline', authMiddleware, digitalDisciplineRoutes);
app.use('/api/content-moderation', authMiddleware, contentModerationRoutes);
export default app;
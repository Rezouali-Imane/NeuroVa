import express from 'express';
import cors from 'cors';
import type { Application } from 'express';
import taskRoutes from './interfaces/routes/Tasks.routes.js';
import taskListRoutes from './interfaces/routes/TaskLists.routes.js';
import authRoutes from './interfaces/routes/Auth.routes.js';
import aiRoutes from './interfaces/routes/AIAssistant.routes.js';
import focusSessionRoutes from './interfaces/routes/FocusSession.routes.js';

const app: Application = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Lightweight health endpoint.
app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// API route registration.
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/tasklists', taskListRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/focus-sessions', focusSessionRoutes);
export default app;
import express from 'express';
import cors from 'cors';
import type { Application } from 'express';
import taskRoutes from './interfaces/routes/Tasks.routes.js';
import taskListRoutes from './interfaces/routes/TaskLists.routes.js';

const app: Application = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// Routes
app.use('/api/tasks', taskRoutes);
app.use('/api/tasklists', taskListRoutes);

export default app;
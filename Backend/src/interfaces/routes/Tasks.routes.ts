import { Router } from 'express';
import { TaskController } from '../controllers/TaskController.js';

const router = Router();

// Add a new task.
router.post('/', TaskController.create);

// Get every task for one user.
router.get('/user/:userid', TaskController.getAll);

// Fetch a single task by ID.
router.get('/:taskid', TaskController.getById);

// Update task fields.
router.put('/:taskid', TaskController.update);

// Update only task status.
router.patch('/:taskid/status', TaskController.updateStatus);

// Remove a task.
router.delete('/:taskid', TaskController.remove);

export default router;
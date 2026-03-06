import { Router } from 'express';
import { TaskController } from '../controllers/TaskController.js';

const router = Router();

// Create a task
router.post('/', TaskController.create);

// Get all tasks for a user
router.get('/user/:userid', TaskController.getAll);

// Get one task by ID
router.get('/:taskid', TaskController.getById);

// Update a task
router.put('/:taskid', TaskController.update);

// Update task status only
router.patch('/:taskid/status', TaskController.updateStatus);

// Delete a task
router.delete('/:taskid', TaskController.remove);

export default router;
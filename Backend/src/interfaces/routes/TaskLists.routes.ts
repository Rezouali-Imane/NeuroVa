import { Router } from 'express';
import { TaskListController } from '../controllers/TaskListController.js';

const router = Router();

// Create a task list
router.post('/', TaskListController.create);

// Get all task lists for a user
router.get('/user/:userid', TaskListController.getAll);

// Update a task list
router.put('/:listid', TaskListController.update);

// Delete a task list
router.delete('/:listid', TaskListController.remove);

export default router;
import { Router } from 'express';
import { TaskListController } from '../controllers/TaskListController.js';

const router = Router();

// Create a new task list.
router.post('/', TaskListController.create);

// Get all task lists for one user.
router.get('/user/:userid', TaskListController.getAll);

// Rename or update a task list.
router.put('/:listid', TaskListController.update);

// Remove a task list.
router.delete('/:listid', TaskListController.remove);

export default router;
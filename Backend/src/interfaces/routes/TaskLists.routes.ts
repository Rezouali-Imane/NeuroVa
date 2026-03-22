import { Router } from 'express';
import { TaskListController } from '../controllers/TaskListController.js';

const router = Router();

router.post('/', TaskListController.create);

router.get('/user/:userid', TaskListController.getAll);

router.put('/:listid', TaskListController.update);

router.delete('/:listid', TaskListController.remove);

export default router;
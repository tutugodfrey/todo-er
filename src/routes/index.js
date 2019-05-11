import express from 'express';
import UsersController from '../controllers/usersController';
import TodoController from '../controllers/todoController';
import { authUser } from '../helpers'

const router = express.Router();

// default route return a nice welcome message
router.get('/', (req, res) => {
  res.status(200).send({ message: 'I touch you wont get me' });
});

// create new user
router.post('/users', UsersController.signUp)
router.post('/users/signin', UsersController.signIn)

// todo routes
router.post('/todos', authUser, TodoController.createTodo);
router.get('/todos', authUser, TodoController.getTodos)
router.get('/todos/:id', authUser, TodoController.getTodo)


export default router;
import express from 'express';
import UsersController from '../controllers/usersController';
import TodoController from '../controllers/todoController';
import { authValidator, todoValidator } from '../middlewares/validation';
import { authUser } from '../helpers'
import upload, { handleUploadedImage } from '../middlewares/fileupload';

const router = express.Router();

// default route return a nice welcome message
router.get('/', (req, res) => {
  res.status(200).send({ message:
    'Welcome to Todo-er! Get your task completed like breeze.' });
});

// create new user
router.post('/users/signup', authValidator.signup, UsersController.signUp);
router.post('/users/signin', authValidator.signin, UsersController.signIn);
router.put('/users', authUser, UsersController.updateUser);
router.get('/users', authUser, UsersController.getUsers);
router.get('/user', authUser, UsersController.getUser);
router.delete('/users/:id', UsersController.deleteUser);
router.post('/users/photo', authUser, upload.single('profilePhoto'),  handleUploadedImage, UsersController.uploadPhoto);

// todo routes
router.post('/todos', authUser, todoValidator.createTodo, TodoController.createTodo);
router.get('/todos', authUser, TodoController.getTodos);
router.get('/todos/:id', authUser, TodoController.getTodo);
router.put('/todos/:id', authUser, TodoController.updateTodo);
router.delete('/todos/:id', authUser, TodoController.deleteTodo);


export default router;

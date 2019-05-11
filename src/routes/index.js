import express from 'express';
import UsersController from '../controllers/usersController';

const router = express.Router();

// default route return a nice welcome message
router.get('/', (req, res) => {
  res.status(200).send({ message: 'I touch you wont get me' });
});

// create new user
router.post('/users', UsersController.signUp)


export default router;
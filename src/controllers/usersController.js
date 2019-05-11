import { users } from '../model';
import bcrypt from 'bcrypt';
import { genToken } from '../helpers'

class UsersController  {
  static signUp(req, res)  {
    const saltRounds = 10;
    const { password } = req.body;
    const salt = bcrypt.genSaltSync(saltRounds);
    const hash = bcrypt.hashSync(password, salt);
    req.body.password = hash;
    return users
      .create(req.body)
      .then(async (user) =>  {
        delete user.password;
        const token = await genToken(user);
        user.token = token
        res.status(201).json({user});
      })
      .catch(err =>  res.status(500).send(err))
  };
}

export default UsersController;

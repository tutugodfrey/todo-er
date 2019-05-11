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
        const { name, username, email } = user;
        const token = await genToken({
          name,
          email,
          username
        });
        res.status(201).json({
          name,
          email,
          username,
          token
        });
      })
      .catch(err =>  res.status(500).send(err))
  };

  static signIn(req, res) {
    // user with username and password
    const { username, password } = req.body;
    return users
      .find({
        where: {
          username
        }
      })
      .then(async user => {
        const verifyUser = bcrypt.compareSync(password, user.password);
        const { name, username, email } = user;
        if (verifyUser) {
          const token = await genToken({
            name,
            username,
            email,
          })
          return res.status(200).json({
            name,
            username,
            email,
            token
          })
        }
      })
      .catch(err => res.status(500).send(err))
  }
}

export default UsersController;

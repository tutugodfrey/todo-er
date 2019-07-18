import { users } from '../model';
import bcrypt from 'bcryptjs';
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
        const { name, username, email, id } = user;
        const token = await genToken({
          id,
          name,
          email,
          username
        });
        res.status(201).json({
          id,
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
        const { name, username, email, id } = user;
        if (verifyUser) {
          const token = await genToken({
            id,
            name,
            username,
            email,
          })
          return res.status(200).json({
            id,
            name,
            username,
            email,
            token
          })
        }
      })
      .catch(err => res.status(500).send(err))
  }

  static updateUser(req, res) {
    let { userId } = req.body;
    const update = req.body
    return users
      .update({
        where: {
          id: userId
        }
      },
      update
      )
      .then(user => {
        const { name, username, email } = user
        return res.status(200).json({
          name,
          email,
          username,
        })
      })
      .catch(err => res.status(500).json(err))
  }

  static getUsers(req, res) {
    return users
      .findAll()
      .then(allUsers => {
        const result = allUsers.map(user => {
          const { name, username, email,id } = user;
          return {
            id,
            name,
            username,
            email
          }
        })
        return res.status(200).json(result)
      })
      .catch(error => res.status(500).json(error))
  }
}

export default UsersController;

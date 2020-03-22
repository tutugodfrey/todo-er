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
    delete req.body.confirmPassword;
    req.body.imgUrl = req.body.imgUrl || ''
    return users
      .create(req.body)
      .then(async (user) =>  {
        const { name, username, email, id, imgUrl } = user;
        const token = await genToken({
          id,
          name,
          email,
          username,
        });
        return res.status(201).json({
          id,
          name,
          email,
          username,
          token,
          imgUrl,
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
        const { name, username, email, id, imgUrl } = user;
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
            imgUrl,
            token
          })
        }
      })
      .catch(err => {
        if(err.message && err.message === 'user not found') {
          return res.status(404).send(err)
        };
        return res.status(500).send(err);
      });
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
        const user_ = { ...user }
        delete user_.password;
        return res.status(200).json(user_)
      })
      .catch(err => res.status(500).json(err))
  }

  static getUsers(req, res) {
    return users
      .findById(req.body.userId)
      .then(result => {
        if (!result.isAdmin) return res.status(401).json({
          message: 'Access denied! Only an admin can view all users'
        });
        return users
          .findAll()
          .then(allUsers => {
            const result = allUsers.map(user => {
              delete user.password
              return user
            })
            return res.status(200).json(result)
          })
      })
      .catch(error => res.status(500).json(error))
  }

  static getUser(req, res) {
    let { userId } = req.body;
    return users
    .findById(userId)
    .then(user => {
      const retrievedUser = { ...user }
      delete retrievedUser.password;
      return res.status(200).json(retrievedUser);
    })
    .catch(error => res.status(500).json(error))
  }

  static deleteUser(req, res) {
    let { id } = req.params;
    return users
      .destory({
        id,
      })
      .then(res => {
        return res.status(200).json({
          message: 'user successfully deleted'
        });
      })
      .catch(err => {
        if (err.message && err.message === 'user not found')
          return res.status(404).json(err);
        return res.status(500).json(err)
      })
  }

  static uploadPhoto(req, res) {
    const { profilePhoto, userId } = req.body;
    return users
    .update({
      where: {
        id: userId
      }
    },
    {
      imgUrl: profilePhoto || ''
    }
    )
    .then(user => {
      const user_ = { ...user }
      delete user_.password;
      return res.status(200).json(user_)
    })
    .catch(err => res.status(500).json(err))
  }
}

export default UsersController;

import chai from 'chai';
import chaiHttp from 'chai-http';

import app from '../index';
import { testUsers, requestHelper } from '../../helpers'
import { users, todos } from '../model';

chai.use(chaiHttp);
const { expect } = chai;

let user1 = {};
let user2 = {};
const signUpRoute = '/api/users/signup';
const signInRoute = '/api/users/signin';
const getUsersRoute = '/api/users';
const getUserRoute = '/api/user';
const {
  postRequest,
  putRequest,
  getRequest
} = requestHelper;

describe('User Test', () => {
  before(() => {
    try {
     users.clear();
    } catch(err) {
      console.log(err)
    }
    return
  });
  before(() => {
    try {
     todos.clear();
    } catch(err) {
      console.log(err)
    }
    return
  });


  describe('Create New User', () => {
    it('should not create without password', () => {
      const user = {...testUsers.user1}
      delete user.password;
      delete user.wrongPassword
      return postRequest(signUpRoute, user)
      .then(res => {
        expect(res.status).to.equal(400)
        expect(res.body).to.have.property('message')
          .to.equal('password is required to sign up');
      });
    });

    it('should not create without confrmPassword', () => {
      const user = {...testUsers.user1}
      delete user.confirmPassword;
      delete user.wrongPassword
      return postRequest(signUpRoute, user)
      .then(res => {
        expect(res.status).to.equal(400)
        expect(res.body).to.have.property('message')
          .to.equal('confirmPassword is required to sign up');
      });
    });

    it('should not create if password and confirmPassword does not match', () => {
      const user = {...testUsers.user1}
      user.confirmPassword = `${user.assword}123`;
      delete user.wrongPassword
      return postRequest(signUpRoute, user)
      .then(res => {
        expect(res.status).to.equal(401)
        expect(res.body).to.have.property('message')
          .to.equal('Passwords does not match');
      });
    });

    it('should not create a user without name', () => {
      const user = { ...testUsers.user1 }
      delete user.name;
      return postRequest(signUpRoute, user)
        .then((res) => {
          expect(res.status).to.equal(400);
          expect(res.body).to.have.property('message').to.equal('name is required to sign up');
        });
    });

    it('should not create a user without an email address', () => {
      const user = { ...testUsers.user1 };
      delete user.email;
      return postRequest(signUpRoute, user)
        .then(res => {
          expect(res.status).to.equal(400)
          expect(res.body).to.have.property('message')
            .to.equal('email is required to sign up');
        });
    });

    it('should not create a user without username', () => {
      const user = { ...testUsers.user1 };
      delete user.username;
      return postRequest(signUpRoute, user)
        .then(res => {
          expect(res.status).to.equal(400);
          expect(res.body).to.have.property('message')
            .to.equal('username is required to sign up');
        });
    });

    it('should create a new user and return a token 1', () => {
      const user = { ...testUsers.user1 };
      delete user.wrongPassword;
      return postRequest(signUpRoute, user)
        .then(res => {
          expect(res.status).to.equal(201)
          expect(res.body).to.have.property('token')
          expect(res.body).to.have.property('username')
            .to.equal(user.username);
          expect(res.body).to.have.property('imgUrl').to.equal('')
          user1 = {...res.body }
        })
        .catch(error => console.log(error));
    });

    it('should create a new user and return a token 2', () => {
      const user = { ...testUsers.user2 };
      delete user.wrongPassword;
      return postRequest(signUpRoute, user)
      .then(res => {
        expect(res.status).to.equal(201)
        expect(res.body).to.have.property('token')
        expect(res.body).to.have.property('username')
          .to.equal(user.username);
        expect(res.body).to.have.property('imgUrl').to.equal('')
        user2 = {...res.body }
      });
    });
  });

  describe('User Signin', () => {
    it('should not sign with password', () => {
      const user = {};
      user.username = testUsers.user1.username;
      return postRequest(signInRoute, user)
      .then(res => {
        expect(res.status).to.equal(400)
      });
    });

    it('should not sign with username', () => {
      const user = {};
      user.password = testUsers.user1.password;
      return postRequest(signInRoute, user)
      .then(res => {
        expect(res.status).to.equal(400)
      });
    });

    it('should not signin if username or password is incorrect', () => {
      const user = { ...testUsers.wrongUser1 };
      return postRequest(signInRoute, user)
      .then(res => {
        expect(res.status).to.equal(404);
        expect(res.body).to.have.property('message')
          .to.equal('user not found');
      });
    });

    it('should signin if username amd password is correct', () => {
      const user = {};
      user.username = testUsers.user1.username;
      user.password = testUsers.user1.password;
      return postRequest(signInRoute, user)
      .then(res => {
        expect(res.status).to.equal(200);
        expect(res.body).to.have.property('token');
        expect(res.body).to.have.property('username')
          .to.equal(user1.username);
        expect(res.body).to.have.property('imgUrl').to.equal('');
      });
    });
  });

  describe('Get User', () => {
    it('should get a with the supplied token', () => {
      return getRequest(getUserRoute, user1.token)
      .then(res => {
        expect(res.body).to.have.property('name')
          .to.equal(user1.name);
        expect(res.body).to.have.property('username')
          .to.equal(user1.username); 
        expect(res.body).to.have.property('email')
          .to.equal(user1.email);
        expect(res.body).to.have.property('imgUrl').to.equal('');

      })
    });
    it('should get a with the supplied token', () => {
      return getRequest(getUserRoute, user2.token)
      .then(res => {
        expect(res.body).to.have.property('name')
          .to.equal(user2.name);
        expect(res.body).to.have.property('username')
          .to.equal(user2.username); 
        expect(res.body).to.have.property('email')
          .to.equal(user2.email);
        expect(res.body).to.have.property('imgUrl').to.equal('');
      });
    });

    it('should return all user if token owner is an admin', () => {
      return getRequest(getUsersRoute, user1.token)
      .then(res => {
        expect(res.status).to.equal(200);
        expect(res.body.length).to.equal(2);
      });
    });

    it('should return all user if token owner is an admin', () => {
      return getRequest(getUsersRoute, user2.token)
      .then(res => {
        expect(res.status).to.equal(401);
        expect(res.body).to.have.property('message')
          .to.equal('Access denied! Only an admin can view all users');
      });
    });
  });

  describe('Update User', () => {
    it('should update user detail', () => {
      const user = {
        username: `${user2.name} updated`
      }
      return putRequest(getUsersRoute, user, user2.token)
        .then(res => {
          expect(res.status).to.equal(200)
          expect(res.body.id).to.equal(user2.id)
        });
    });
  });
});

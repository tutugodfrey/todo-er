import chai from 'chai';
import chaiHttp from 'chai-http';
import app from '../index';
import { users, todos } from '../model';
import { testTodos, testUsers, requestHelper } from '../../helpers';

chai.use(chaiHttp);
const { expect } = chai;
const baseUrl = '/api/todos';
let wrongToken = 'somereallyreallywrongtokenwithouthorigin';
let user1 = {}
let user2 = {}
let user2Todo = [];
const {
  getRequest,
  postRequest,
  deleteRequest,
  putRequest
} = requestHelper;
describe('Todos Test', () => {
  before(() => {
    try {
      users.clear();
    } catch(err) {
      console.log(err)
    }
  });
  before(() => {
    try {
      todos.clear();
    } catch(err) {
      console.log(err)
    }
  });

  before(() => {
    const user2_ = testUsers.user2;
    delete user2_.wrongPassword;
    return chai.request(app)
      .post('/api/users/signup')
      .send(user2_)
      .then(res => {
        user2 = { ...res.body }
      });
  });

  before(() => {
    const user1_ = testUsers.user1;
    user1.isAdmin = false;
    delete user1_.wrongPassword;
    return chai.request(app)
      .post('/api/users/signup')
      .send(user1_)
      .then(res => {
        user1 = { ...res.body }
      });
  });
  describe('Create Todo', () => {
    it('should not create todo without title', () => {
      const todo = { ...testTodos.todo1 };
      delete todo.title;
      return postRequest(baseUrl, todo, user2.token)
        .then(res => {
          expect(res.status).to.equal(400);
          expect(res.body).to.have.property('message')
            .to.equal('title is required to create todo')
        });
    });

    it('should not create todo without title', () => {
      const todo = { ...testTodos.todo1 };
      delete todo.description;
      return postRequest(baseUrl, todo, user2.token)
        .then(res => {
          expect(res.status).to.equal(400);
          expect(res.body).to.have.property('message')
            .to.equal('description is required to create todo')
        });
    });
  
    it('should create todo with all required fields 1', () => {
      const todo = { ...testTodos.todo1 };
      return postRequest(baseUrl, todo, user2.token)
        .then(res => {
          expect(res.status).to.equal(201);
          expect(res.body).to.have.property('id');
          expect(res.body).to.have.property('userId').to.equal(user2.id);
          expect(res.body).to.have.property('completed').to.equal(false);
          expect(res.body).to.have.property('title').to.equal('todo1 title');
          // expect(res.body).to.have.property('links').to.have.length(2);
          user2Todo.push(res.body);
        });
    });

    it('should create todo with all required fields 2', () => {
      const todo = { ...testTodos.todo2 };
      return postRequest(baseUrl, todo, user2.token,)
        .then(res => {
          expect(res.status).to.equal(201)
          expect(res.body).to.have.property('id');
          expect(res.body).to.have.property('userId').to.equal(user2.id);
          expect(res.body).to.have.property('completed').to.equal(false);
          expect(res.body).to.have.property('title').to.equal('todo2 title');
          // expect(res.body).to.have.property('links').to.have.length(2);
          user2Todo.push(res.body);
        });
    });
  });

  describe('Get Todos', () => {
    it('shoud not get todo with an invalid token', () => {
      return getRequest(baseUrl, wrongToken)
        .then(res => {
          expect(res.status).to.equal(401);
          expect(res.body).to.have.property('message').to.equal('invalid token');
        });
    });

    it('should not return todos created by other users', () => {
      return getRequest(baseUrl, user1.token)
        .then(res => {
          expect(res.status).to.equal(200);
          expect(res.body).to.have.length(0);
        });
    });

    it('should get todos for the user with token', () => {
      return getRequest(baseUrl, user2.token)
        .then(res => {
          expect(res.status).to.equal(200);
          expect(res.body).to.have.length(2);
        });
    });
  });

  describe('Update Todos', () => {
    it('should not update a todo that does not exist', () => {
      const todo = {
        completed: true,
      }
      return putRequest(`${baseUrl}/4`, todo, user2.token)
        .then(res => {
          expect(res.status).to.equal(404)
          expect(res.body).to.have.property('message').to.equal('todo not found');
        });
    });

    it('should update todo of user with token', () => {
      const todo = {
        completed: true,
      }
      return putRequest(`${baseUrl}/${user2Todo[0].id}`, todo, user2.token)
        .then(res => {
          expect(res.status).to.equal(200);
          expect(res.body).to.have.property('userId').to.equal(user2.id);
          expect(res.body).to.have.property('completed').to.equal(true);
        })
        .catch(err => console.log(err))
    })
  });

  describe('Delete todos', () => {
    it('user should not delete todo they do not create', () => {
      return deleteRequest(`${baseUrl}/${user2Todo[1].id}`, user1.token)
        .then(res => {
          expect(res.status).to.equal(404)
          expect(res.body).to.have.property('message')
            .to.equal('todo not found, not action taken');
        });
    });

    it('should delete todos for user with token', () => {
      return deleteRequest(`${baseUrl}/${user2Todo[1].id}`, user2.token)
        .then(res => {
          expect(res.status).to.equal(200);
          expect(res.body).to.have.property('message')
            .to.equal('todo has been deleted');
        });
    });
  });
});

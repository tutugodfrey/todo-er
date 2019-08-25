import chai from 'chai';
import chaiHttp from 'chai-http';

import app from '../index';
chai.use(chaiHttp);
const { expect } = chai;

describe('Server', () => {
  it('should get welcome message', () => {
    return chai.request(app)
    .get('/api')
    .then(res => {
      expect(res.status).to.equal(200);
      expect(res.body.message).to.equal(
        'Welcome to Todo-er! Get your task completed like breeze.'
      )
    })
  });
});

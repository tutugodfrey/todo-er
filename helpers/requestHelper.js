import chai from 'chai';
import chaiHttp from 'chai-http';
import app from '../src/index';

chai.use(chaiHttp);

export default{
  postRequest: (route, data, token='') => {
    return chai.request(app)
      .post(route)
      .set('token', token)
      .send(data)
      .then(res => res);
  },
  putRequest: (route, data, token='') => {
    return chai.request(app)
      .put(route)
      .set('token', token)
      .send(data)
      .then(res => res);
  },
  getRequest: (route, token) => {
    return chai.request(app)
      .get(route)
      .set('token', token)
      .then(res => res);
  },
  deleteRequest: (route, token) => {
    return chai.request(app)
      .delete(route)
      .set('token', token)
      .then(res => res);
  }
}

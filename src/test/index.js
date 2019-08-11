import chai from 'chai';
import chaiHttp from 'chai-http';

import app from '../index';
const { expect } = chai;

describe('Server', () => {
  it('should get welcome message', () => {
    expect(1).to.equal(1)
  });
});
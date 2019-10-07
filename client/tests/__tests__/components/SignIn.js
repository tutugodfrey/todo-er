import React from 'react';

import { SignIn } from '../../../components/Signin';
import { testUsers } from '../../../../helpers'

let wrapper;
let inputs;
let links;
let username;
let password;
let submitBtn;
const userStore = {
  setUser: jest.fn(),
}
let spyOnSignIn;
describe('Signin Component', () => {
  beforeAll(() => {
    spyOnSignIn = jest.spyOn(SignIn.prototype, 'onSignIn');
    wrapper = shallow(<SignIn userStore={ userStore } history={[]}/>);
    inputs = wrapper.find('input');
    links = wrapper.find('Link');
    spyOnSignIn
  });

  beforeEach(() => {
    // fetch.resetMocks();
    username = inputs.at(0);
    password = inputs.at(1);
    submitBtn = inputs.at(2);
    username.simulate('change', {
      preventDefault: () => {},
      target: {
        name: 'username',
        value: 'Esanye',
      }
    });

    password.simulate('change', {
      preventDefault: () => {},
      target: {
        name: 'password',
        value: 'Aa!12345',
      }
    });

    submitBtn.simulate('click', {
      preventDefault: () => {},
    });
  });

  test('should find all input elements', () => {
    expect(inputs.length).toBe(3);
    expect(username.props().name).toBe('username');
    expect(password.props().name).toBe('password');
    expect(submitBtn.props().value).toBe('Sign In');
  });

  describe('Unsuccessful Signin', () => {
    fetch.mockResponseOnce(JSON.stringify({ message: 'user not found' }))
    test('should render console modal component', () => {
      const consoleModal = wrapper.find('ConsoleModal');
      expect(consoleModal.length).toBe(1);
      expect(consoleModal.props()
        .message).toBe('Unsuccessful login! Please check your username and password');
      expect(spyOnSignIn).toHaveBeenCalledTimes(1)
    });
  });

  describe('Successful Signin', () => {
    beforeAll(() => {
      wrapper = shallow(<SignIn { ...userStore }/>);
      inputs = wrapper.find('input');
      links = wrapper.find('Link');
    });
    const user = { ...testUsers.user2 };
    user.token = 'somerandomstringfortoken'
    fetch.mockResponseOnce(JSON.stringify({
      ...user
     }));
    test('should render console modal component', () => {
      const consoleModal = wrapper.find('ConsoleModal');
      expect(consoleModal.length).toBe(0);
      expect(localStorage.getItem('token')).toBe(user.token);
      expect(spyOnSignIn).toHaveBeenCalled()
    });
  });

  describe('Links', () => {
    test('should render link to home page', () => {
      const linkToHome = links.at(0);
      const props = linkToHome.props();
      expect(props.to).toBe('/');
      expect(props.children).toEqual(expect.stringContaining('Back'));
    });

    test('should render link to signup page', () => { 
      const linkToSignup = links.at(1)
      const props = linkToSignup.props();
      expect(props.to).toBe('/signup');
      expect(props.children).toBe('Sign Up');
    });
  });


});

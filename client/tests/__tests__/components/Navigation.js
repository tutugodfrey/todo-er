import React from 'react';
import { Navigation } from '../../../components/Navigation';

const wrapper = shallow(<Navigation />);

describe('Navigation Component Test', () => {
  test('should render signup, signin links without user authentication', () => {
    expect(wrapper.props().id).toBe('nav-bar');
    expect(wrapper.name()).toBe('div');

    // render signup and signin if not auth
    expect(wrapper.children().length).toBe(2);

    expect(wrapper.childAt(0).props().id).toBe('signin');
    expect(wrapper.childAt(0).find('Link').props().children).toBe('Sign In');
    expect(wrapper.childAt(0).find('Link').props().to).toBe('/signin');

    expect(wrapper.childAt(1).props().id).toBe('signup');
    expect(wrapper.childAt(1).find('Link').props().children).toBe('Sign Up');
    expect(wrapper.childAt(1).find('Link').props().to).toBe('/signup');
  });

  describe('When use login with token in localstorage', () => {
    window.localStorage.setItem('token', 'some token string');
    const wrapper = shallow(<Navigation />);
    test('Find render n', () => {
      expect(wrapper.children().length).toBe(4)
      expect(wrapper.childAt(0).props().id).toBe('home');
      expect(wrapper.childAt(0).find('Link').props().children).toBe('Home');
      expect(wrapper.childAt(0).find('Link').props().to).toBe('/');

      expect(wrapper.childAt(1).props().id).toBe('dashboard');
      expect(wrapper.childAt(1).find('Link').props().children).toBe('Tasks');
      expect(wrapper.childAt(1).find('Link').props().to).toBe('./dashboard');

      expect(wrapper.childAt(2).props().id).toBe('profile');
      expect(wrapper.childAt(2).find('Link').props().children).toBe('Profile');
      expect(wrapper.childAt(2).find('Link').props().to).toBe('./profile');

      expect(wrapper.childAt(3).props().id).toBe('logout');
      expect(wrapper.childAt(3).find('a').props().children).toBe('Log Out');;
    });
  });
});

import React from 'react';
import { shallow, mount } from 'enzyme';
import { shape } from 'prop-types'
import Home from '../../../components/Home.jsx';
import { Link, MemoryRouter  } from 'react-router-dom';

const options = {
  context: {
    router: {
      history: {
        push: jest.fn(),
        replace: jest.fn(),
        createHref: jest.fn(),
      },
      route: {
        location: {
          hash: '',
          pathname: '',
          search: '',
          state: '',
        },
        match: {
          params: {},
          isExact: false,
          path: '',
          url: '',
        },
      },
    },
  },
  childContextTypes: {
    router: shape({
      route: shape({
        location: shape(),
        match: shape(),
      }),
      history: shape({}),
    }),
  },
};

let wrapper
describe('<Home /> component test', () => {
  beforeAll(() => {
    wrapper = mount(<MemoryRouter>
      <Home />
      </MemoryRouter>);
  });

  it('should find the welcome message', () => {
    const heading = wrapper.find('h1');
    expect(heading.text()).toBe('Don\'t leave any task uncompleted!')
  });

  test('should find info heading', () => {
    const vara = wrapper.find('#story');
    expect(vara.type()).toBe('strong');
    expect(vara.text()).toBe('Start using Todo-er');
  });

  test('should find the signup link', () => {
    const signup = wrapper.find(Link).first();
    expect(signup.text()).toBe('Sign Up')
    signup.simulate('click')
  })
})

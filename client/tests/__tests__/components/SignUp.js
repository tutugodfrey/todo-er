import React from 'react';
import { Signup } from '../../../components/SignUp.jsx';
import { shallow } from 'enzyme';

let wrapper;
describe('<SignUp />', () => {
  beforeAll(() => {
    wrapper = shallow(<Signup />);
  })

  test('should find the heading text', () => {
    const heading = wrapper.find('h3').text();
    expect(heading).toBe('Sign Up');
  })
  test('should render signup page', () => {
    const div = wrapper.find('.sign-up').length;
    expect(div).toBe(1)
  });

  test('should find all input elements', () => {
    const inputs = wrapper.find('.sign-up').find('input').length;
    expect(inputs).toBe(6);
  });
  test('should find all labels', () => {
    const labels = wrapper.find('label');
    expect(labels.length).toBe(5)
  });
  test('should an instance of Signup', () => {
    const instance = wrapper.instance();
    expect(instance).toBeInstanceOf(Signup)
  });
  test('should get submit button and click', () => {
    const button = wrapper.find('input').get(5);
    expect(button.props.type).toBe('submit');
    wrapper.find('#submit-btn').simulate('submit')
  });

  test('should signup', () => {
    const handleSubmit = jest.fn()
    wrapper.setState({
      user: {
        fullname: 'John Doe',
        username: 'johnd',
        email: 'johnd@email.com',
        password1: 'Aa!12345',
        password2: 'Aa!12345',
      }
    });

    wrapper.instance().handleSubmit({
      target: {},
      preventDefault: () => {},
  })
    // expect(wrapper.handleSubmit).toHaveBeenCalled()
  });
});

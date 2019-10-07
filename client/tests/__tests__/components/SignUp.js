import React from 'react';
import { Signup } from '../../../components/Signup';
import { testUsers } from '../../../../helpers';

let wrapper;
fetch.mockResponseOnce(JSON.stringify({
  ...testUsers.user1,
 }));
let spyOnHandleSubmit;
describe('<SignUp />', () => {
  beforeAll(() => {
    spyOnHandleSubmit = jest.spyOn(Signup.prototype, 'handleSubmit');
    wrapper = shallow(<Signup />);
  });

  test('should find the heading text', () => {
    const heading = wrapper.find('h3').text();
    expect(heading).toBe('Sign Up');
  })
  test('should render signup page', () => {
    const div = wrapper.find('.sign-up').length;
    expect(div).toBe(1);
  });

  test('should find all input elements', () => {
    const inputs = wrapper.find('.sign-up').find('input').length;
    expect(inputs).toBe(6);
  });
  test('should find all labels', () => {
    const labels = wrapper.find('label');
    expect(labels.length).toBe(5);
  });
  test('should an instance of Signup', () => {
    const instance = wrapper.instance();
    expect(instance).toBeInstanceOf(Signup);
  });
  test('should get submit button and click', () => {
    const button = wrapper.find('input').get(5);
    expect(button.props.type).toBe('submit');
    wrapper.find('#submit-btn').simulate('click');
  });

  test('should signup', () => {
    expect(spyOnHandleSubmit).not.toHaveBeenCalled();
    expect(spyOnHandleSubmit).toHaveBeenCalledTimes(0);
  });
});

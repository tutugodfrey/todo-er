import React from 'react';
import { LoginInline } from '../../../components/LoginInline';

const wrapper = shallow(<LoginInline />);
describe('LoginInline Test', () => {
  test('wrapper is a div', () => {
    expect(wrapper.is('div')).toBeTruthy();
    expect(wrapper.props().id).toBe('login-inline');
    expect(wrapper.length).toBe(1);
    expect(wrapper.children().first().is('form')).toBeTruthy()
  });

  test('should find the id of the component', () => {
    const eleId = wrapper.find('form');
    expect(eleId.childAt(0).name()).toBe('div');
    expect(eleId.childAt(0).type()).toBe('div');
    expect(eleId.childAt(0).props().id).toBe('form-group_container')
    expect(eleId.childAt(0).children().length).toBe(3);
  });

  test('should find all input fields', () => {
    const inputs = wrapper.find('input');
    expect(inputs.length).toBe(3);
    expect(inputs.at(0).props().type).toBe('text');
    expect(inputs.at(0).props().name).toBe('username');
    expect(inputs.at(1).props().type).toBe('password');
    expect(inputs.at(1).props().name).toBe('password');
    expect(inputs.at(2).props().type).toBe('submit');
    expect(inputs.at(2).props().value).toBe('Sign In')
  });
});

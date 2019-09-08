import React from 'react';
import { Home } from '../../../components/Home.jsx';

let wrapper = shallow(<Home />);
describe('<Home /> component test', () => {
  it('should find the welcome message', () => {
    const heading = wrapper.find('h1');
    expect(heading.text()).toBe('Don\'t leave any task uncompleted!')
  });

  test('should find info heading', () => {
    const vara = wrapper.find('#story');
    expect(vara.type()).toBe('p');
    expect(vara.text()).toBe('Task marker let you keep track of your goals for the day');
  });

  test('should find the LoginInline component', () => {
    expect(wrapper.children().at(1).children().childAt(1).name())
      .toBe('inject-withRouter(LoginInline)-with-userStore');
      expect(wrapper.childAt(0).name()).toBe('withRouter(Navigation)');
  });
});

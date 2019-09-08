import React from 'react';
import { Todo } from '../../../components/Todo';
import { testTodos, testUsers } from '../../../../helpers';

const { user1 } = testUsers;
const { todo1 } = testTodos;
todo1.id = 1;
const todos = [todo1];
const userStore = {
  setUser: jest.fn(),
  getUser: user1
}
const todoStore = {
  setTodo: jest.fn(),
  todos: [],
}
let wrapper;
fetch.mockResponseOnce(JSON.stringify({
  ...todo1
 }));
describe('Todo test', () => {
  beforeAll(() => {
    wrapper = shallow(<Todo todoStore={ todoStore } userStore={ userStore } />);;
  })
  describe('Top level div', () => {
    test('should have id todos-container', () => {
      expect(wrapper.type()).toBe('div');
      expect(wrapper.props().id).toEqual('todos-container');
    });

    test('should contain 2 children div', () => {
      expect(wrapper.children().length).toBe(2)
      expect(wrapper.children().at(0).props().id).toBe('todo-form_control');
      expect(wrapper.children().at(1).props().id).toBe('todos-content_div');
    })
  });

  describe('Todo form', () => {
    // const wrapper = shallow(<Todo todoStore={{ todos: [] }} />);
    let todoFormDiv;
    let childrenDiv
    beforeAll(() => {
      todoFormDiv = wrapper.find('#todo-form_control');
      childrenDiv = todoFormDiv.children();
    });

    test('should contain 2 children element', () => {
      expect(todoFormDiv.children().length).toBe(2);
    });

    test('should contian toggle-todo-form_div', () => {
      expect(childrenDiv.at(0).name()).toEqual('div');
      expect(childrenDiv.at(0).props().id).toEqual('toggle-todo-form_div');
    });

    test('should contain todo form', () => {
      expect(childrenDiv.at(1).name()).toEqual('inject-TodoForm-with-todoStore');
    });

    test('should not find toggle todo button', () => {
      const toggleTodoBtn = wrapper.find('#toggle-todoform_button');
      expect(toggleTodoBtn.length).toBe(0);
    });
  });

  describe('Edit mode off', () => {
    let todosContentDiv;
    let childrenDiv;
    beforeAll(() => {
      todoStore.todos.push(todo1);
      wrapper = shallow(<Todo todoStore={ todoStore } />);
      todosContentDiv = wrapper.find('#todos-content_div');
      childrenDiv = todosContentDiv.children();
    });
    test('should find toggle todo form button', () => {
      const toggleTodoBtn = wrapper.find('#toggle-todoform_button');
      expect(toggleTodoBtn.length).toBe(1);
      expect(toggleTodoBtn.type()).toBe('button');
      expect(toggleTodoBtn.props().children).toBe('New Task');
    });

    test('should contain to elements', () => {
      expect(childrenDiv.length).toBe(2);
    });

    test('should find the todos header', () => {
      expect(childrenDiv.at(0).type()).toBe('h3');
      expect(childrenDiv.at(0).text()).toBe('Your Todos')
    });

    test('should find rendered todos', () => {
      const todos = wrapper.find('.todo');
      const children = todos.children();
      expect(todos.length).toBe(1);
      expect(children.length).toBe(2);
      expect(children.at(0).props().className).toBe('todo-bar');
      expect(children.at(1).props().id).toBe('toggle-todo-1-main')
    });
  });

  describe('Edit mode on', () => {
    let editBtn;
    let inputs;
    let links;
    beforeAll(() => {
      // todoStore.todos.push(todo1);
      // wrapper = shallow(<Todo todoStore={ todoStore } />);
      // wrapper = shallow(<Todo todoStore={{ todos }} />);
      editBtn = wrapper.find('.edit-todo');
      editBtn.simulate('click');
      inputs = wrapper.find('input');
      links = wrapper.find('span');
    });

    test('should find edit todo button', () => {
      expect(editBtn.length).toBe(1);
    });

    test('should render previous title', () => {
      const title = inputs.at(0);
      const props = title.props();
      expect(props.name).toBe('title');
      expect(props.value).toBe(todo1.title)
    });

    test('should render previous description', () => {
      const description = inputs.at(1);
      const props = description.props();
      expect(props.name).toBe('description');
      expect(props.value).toBe(todo1.description);
    });

    test('should render previous linkText', () => {
      const linkText = inputs.at(2);
      const props = linkText.props();
      expect(props.name).toBe('linkText');
      expect(props.value).toBe('');
    });

    test('should render previous link url', () => {
      const linkUrl = inputs.at(3);
      const props = linkUrl.props();
      expect(props.name).toBe('url');
      expect(props.value).toBe('')
    });

    test('should find todo links', () => {
      expect(links.length).toBe(2);
      expect(links.at(0).childAt(0).type()).toBe('button');
      expect(links.at(0).childAt(1).type()).toBe('a');
      expect(links.at(0).childAt(1).props().href).toBe(todo1.links[0].url);
      expect(links.at(0).childAt(1).props().children).toBe(todo1.links[0].url)

      expect(links.at(1).childAt(0).type()).toBe('button');
      expect(links.at(1).childAt(1).type()).toBe('a');
      expect(links.at(1).childAt(1).props().href).toBe(todo1.links[1].url);
      expect(links.at(1).childAt(1).props().children).toBe(todo1.links[1].linkText);
    });
  });
});

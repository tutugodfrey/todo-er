import React, { Component } from 'react';
import TodoForm from './TodoForm.jsx';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { request } from '../helpers';

class Todo extends Component {
  constructor() {
    super()
    this.toggleCompleted = this.toggleCompleted.bind(this)
    this.state = {
      completeTodo: {
        completed: false,
      }
    }
  }
  async componentWillMount() {
    const todos = await request('/todos', 'GET');
    this.props.todoStore.setTodo(todos)
  }

  async toggleCompleted(event) {
    this.setState({
      ...this.state,
      completeTodo: {
        completed: !this.state.completeTodo.completed,
      }
    })
    const updatedTodo = await request(
      `/todos/${event.target.value}`,
      'PUT',
      this.state.completeTodo
    );
    this.props.todoStore.updateTodo(updatedTodo)
  }

  render() {
    const todos = this.props.todoStore.todos;
    return (
      <div>
        <TodoForm />
        <div>
          <ul>
          {todos && todos.map(todo => {
            return (
              <li key={todo.id}>
                <div>
                  <strong>Title:</strong><span>{todo.title}</span><br />
                  <strong>Description:</strong><span>{todo.description}</span><br />
                  <input
                    type="checkbox"
                    checked={todo.completed}
                    value={todo.id}
                    onChange={this.toggleCompleted}
                  />
                  <button type="button">Edit</button>
                </div>
              </li>
            )})
          }
          </ul>
        </div>
      </div>
    )
  }
}

export default compose(
  inject('todoStore'),
  observer,
)(Todo);

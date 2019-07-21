import React, { Component } from 'react';
import TodoForm from './TodoForm.jsx';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { request } from '../helpers';

const CompleteTodoCheckbox = ({ todo, toggleCompleted }) => (
  <input
    id={`todo-${todo.id}`}
    type="checkbox"
    checked={todo.completed}
    value={todo.id}
    onChange={toggleCompleted}
  />
)
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

  toggleTodoDisplay (event) {
    const { id } = event.target;
    event.target.textContent === "Show" ?
      event.target.textContent = 'Hide' :
      event.target.textContent = 'Show';

    const todoDiv = document.getElementById(`${id}-main`);
    if (todoDiv.classList.contains('hide-item')) {
      todoDiv.classList.replace('hide-item', 'show-item')
    }  else if (todoDiv.classList.contains('show-item')) {
      todoDiv.classList.replace('show-item', 'hide-item')
    }

    const miniTodoDiv = document.getElementById(`${id}-mini`);
    if (miniTodoDiv.classList.contains('visible')) {
      miniTodoDiv.classList.replace('visible', 'hidden')
    }  else if (miniTodoDiv.classList.contains('hidden')) {
      miniTodoDiv.classList.replace('hidden', 'visible')
    }
  }

  render() {
    const todos = this.props.todoStore.todos;
    return (
      <div id="todos-container">
        { !todos.length && <TodoForm /> }
        <div>
          <h3>{todos.length ? 'Your Todos' : 'No Todos! Start adding your tasks'}</h3>
          <ul>
          {todos && todos.map(todo => {
            return (
              <div className="todo" key={todo.id}>
                <div className="todo-bar">
                  <div id={`toggle-todo-${todo.id}-mini`} className="visible mini-todo-content">
                    <div className="todo-bar_title">{todo.title}</div>
                    <div>{todo.completed &&
                      <CompleteTodoCheckbox
                        todo={todo}
                        toggleCompleted={this.toggleCompleted.bind(this)}
                      />}
                    </div>
                  </div>
                  <div>
                    <button id={`toggle-todo-${todo.id}`} onClick={this.toggleTodoDisplay.bind(this)}>Show</button>
                  </div>
                </div>
                <div id={`toggle-todo-${todo.id}-main`} className={'hide-item todos'}>
                  <li key={todo.id}>
                    <div>
                      <strong>Title: </strong><span>{todo.title}</span><br />
                      <strong>Description: </strong><span>{todo.description}</span><br />
                      <CompleteTodoCheckbox
                        todo={todo}
                        toggleCompleted={this.toggleCompleted.bind(this)}
                      />
                      <label htmlFor={`todo-${todo.id}`}> Completed</label><br />
                      <button type="button" className="edit-todo">Edit</button>
                      <button type="button" className="delete-todo">Delete</button>
                    </div>
                  </li>
                </div>
              </div>
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

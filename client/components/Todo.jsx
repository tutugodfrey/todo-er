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
      },
      showTodoForm: true,
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

  toggleTodoForm(event) {
    this.setState({
      showTodoForm: !this.state.showTodoForm,
    })
  }

  render() {
    const todos = this.props.todoStore.todos;
    const { showTodoForm } = this.state;
    return (
      <div id="todos-container">
        <div id="todo-form_control">
          <div id="toggle-todo-form_div">
              <button id='toggle-todoform_button' onClick={this.toggleTodoForm.bind(this)}>{showTodoForm ? 'Close Form': 'New Task'}</button>
          </div>
          { (!todos.length || showTodoForm) && <TodoForm /> }
        </div>
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
                      <div>
                        <strong>Title: </strong><span>{todo.title}</span>
                      </div>
                      <div>
                        <strong>Description: </strong><span>{todo.description}</span>
                      </div>
                      <div>
                        <strong>Links: </strong>
                        <div>{todo.links && todo.links.length && todo.links.map((link, index)=> {
                          return (
                            <span key={index}>
                              {/* {<button 
                                onClick={event => this.removeLink(event, index)}
                              >x
                              </button>} */}
                              <a href={link.url} target="_blank" rel="noopener noreferrer">{link.linkText || link.url}
                              </a><br />
                            </span>
                          );
                        })}
                        </div>
                      </div>
                      <div>
                        <CompleteTodoCheckbox
                          todo={todo}
                          toggleCompleted={this.toggleCompleted.bind(this)}
                        />
                        <label htmlFor={`todo-${todo.id}`}> Completed</label>
                      </div>
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

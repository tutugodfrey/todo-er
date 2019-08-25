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
      link: {
        url: '',
        linkText: '',
      },
      completeTodo: {
        completed: false,
      },
      showTodoForm: false,
      editMode: false,
      todoToEdit: {},
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

  toggleEditMode(event=null, todo=null) {
    event && event.preventDefault();
    this.setState({
      editMode: !this.state.editMode,
      todoToEdit: todo,
    });
  }

  handleAddChange(event) {
    const { name, value } = event.target;
    this.setState({
      ...this.state,
      todoToEdit: {
        ...this.state.todoToEdit,
        [name]: value,
      }
    })
  }

  handleEnterLink(event) {
    const { name, value } = event.target;
    this.setState({
      link: {
        ...this.state.link,
        [name]: value,
      }
    });
  }

  handleAddLink(event) {
    event.preventDefault();
    this.setState({
      ...this.state,
      todoToEdit: {
        ...this.state.todoToEdit,
        links: [...this.state.todoToEdit.links, this.state.link],
      },
      link: {
        linkText: '',
        url: '',
      },
    });
  }

  removeLink(event, index) {
    event.preventDefault();
    this.state.todoToEdit.links.splice(index, 1);
    this.setState({
      ...this.state,
      todoToEdit: {
        ...this.state.todoToEdit,
        links: [...this.state.todoToEdit.links],
      },
    });
  }

  async updateTodo(event) {
    const { id } = event.target;
    const todoId = parseInt(id.split('-')[2], 10);
    const updatedTodo =
    await request(`/todos/${todoId}`, 'PUT',
      this.state.todoToEdit);
    this.toggleEditMode()
    this.props.todoStore.updateTodo(updatedTodo)
  }

  async handleDeleteTodo(event) {
    const { id } = event.target;
    const todoId = parseInt(id.split('-')[2], 10);
    const deleteResponse =
    await request(`/todos/${todoId}`, 'DELETE');
    if (deleteResponse.message) {
      this.props.todoStore.deleteTodo(todoId);
    }
  }

  render() {
    const todos = this.props.todoStore.todos;
    const { showTodoForm, todoToEdit, editMode } = this.state;
    const $editingTodo = editMode ? 'editing' : '';
    return (
      <div id="todos-container">
        <div id="todo-form_control">
          <div id="toggle-todo-form_div">
              <button
                id='toggle-todoform_button'
                onClick={this.toggleTodoForm.bind(this)}
              >
                {showTodoForm ? 'Close Form': 'New Task'}
              </button>
          </div>
          { (!todos.length || showTodoForm) && <TodoForm /> }
        </div>
        <div>
          <h3>{todos.length ? 'Your Todos' : 'No Todos! Start adding your tasks'}</h3>
          <ul>
          {todos && todos.map(mainTodo => {
            let editing;
            let todo;
            if (editMode && todoToEdit.id === mainTodo.id) {
              editing= true,
              todo = todoToEdit
            } else {
              editing = false;
              todo = mainTodo
            }

            return (
              <div className="todo" key={todo.id}>
                <div className="todo-bar">
                  <div
                    id={`toggle-todo-${todo.id}-mini`}
                    className="visible mini-todo-content"
                  >
                    <div className="todo-bar_title">{todo.title}</div>
                    <div>{todo.completed &&
                      <CompleteTodoCheckbox
                        todo={todo}
                        toggleCompleted={this.toggleCompleted.bind(this)}
                      />}
                    </div>
                  </div>
                  <div>
                    <button
                      id={`toggle-todo-${todo.id}`}
                      onClick={this.toggleTodoDisplay.bind(this)}
                    >Show</button>
                  </div>
                </div>
                <div id={`toggle-todo-${todo.id}-main`} className={'hide-item todos'}>
                  <li key={todo.id}>
                    <div>
                      <div>
                      {editing ?
                        <div id={$editingTodo}>
                          <label className="item-label">Title: </label>
                          <input
                            value={todo.title}
                            name="title"
                            onChange={this.handleAddChange.bind(this)}
                          />
                        </div>
                          : <h3>{todo.title}</h3>
                        }
                      </div>
                      <div>
                      {editing ?
                        <div>
                          <label className="item-label">Description: </label>
                          <input
                            name="description"
                            value={todo.description}
                            onChange={this.handleAddChange.bind(this)}
                          />
                        </div>
                          : <p>{todo.description}</p>
                        }
                      </div>
                      <div id="links-div" className={$editingTodo}>
                        <strong className="item-label">Links </strong>
                        <div>{todo.links && todo.links.length && todo.links.map((link, index)=> {
                          return (
                            <span key={index}>
                              {editing && <button
                                onClick={event => this.removeLink(event, index)}
                              >x</button>}
                              <a href={link.url}
                                target="_blank"
                                rel="noopener noreferrer"
                              >{link.linkText || link.url}
                              </a><br />
                            </span>
                          );
                        })}
                        </div>
                      </div>
                      <div id="check-complete">
                        <CompleteTodoCheckbox
                          todo={todo}
                          toggleCompleted={this.toggleCompleted.bind(this)}
                        />
                        <label htmlFor={`todo-${todo.id}`}> Completed</label>
                      </div>
                      <div>{ editMode &&
                        <fieldset>
                          <legend>
                            Add related links
                          </legend>
                          <input
                            type="text"
                            id="link-text"
                            name="linkText"
                            placeholder='Description'
                            value={this.state.link.linkText}
                            onChange={this.handleEnterLink.bind(this)}
                          />
                          <label htmlFor="description"> Link text</label><br />
                          <input
                            type="text"
                            id="link-url"
                            name="url"
                            placeholder='link'
                            value={this.state.link.url}
                            onChange={this.handleEnterLink.bind(this)}
                          />
                          <button
                            id="update-links"
                            onClick={this.handleAddLink.bind(this)}
                          >Add link</button>
                        </fieldset>}
                      </div>
                      <button
                        type="button"
                        className="edit-todo main-action"
                        id={`edit-todo-${todo.id}`}
                        onClick={event => this.toggleEditMode(event, todo)}
                      >
                        {editing ? "Cancel" : "Edit"}
                      </button>
                      {editing &&
                        <button
                          type="button"
                          className="save-todo-update main-action"
                          id={`edit-todo-${todo.id}`}
                          onClick={this.updateTodo.bind(this)}
                        >Save</button>
                      }
                      <button
                        type="button"
                        className="delete-todo main-action"
                        id={`edit-todo-${todo.id}`}
                        onClick={this.handleDeleteTodo.bind(this)}
                      >Delete</button>
                    </div>
                  </li>
                </div>
              </div>
            )})
          }
          </ul>
        </div>
      </div>
    );
  };
}

export default compose(
  inject('todoStore'),
  observer,
)(Todo);

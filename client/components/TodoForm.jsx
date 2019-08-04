import React, { Component } from 'react';
import { compose } from 'recompose';
import { observer, inject } from 'mobx-react';
import { request } from '../helpers'
class TodoForm extends Component {
  constructor() {
    super()
    this.handleChange = this.handleChange.bind(this);
    this.onSaveTodo = this.onSaveTodo.bind(this);
    this.state = {
      todoObj: {
        title: '',
        description: '',
      }
    }
  };

  handleChange(event) {
    const {name, value } = event.target;
    this.setState({
      ...this.state,
      todoObj: {
        ...this.state.todoObj,
        [name]: value
      }
    })
  };

  async onSaveTodo(event) {
    console.log(this.state.todoObj)
    const todo = await request('/todos', 'POST', this.state.todoObj);
    console.log(todo, 'todo');
    this.props.todoStore.addTodo(todo);
  };

  render() {
    return (
      <div id="todo-form_container">
        <form>
          <div className="form-header">
            <h3>Add a Task to Complete</h3>
          </div>
          <div className="form-group">
            <label htmlFor="title">Add Title</label><br />
            <input
              type="text"
              id="title"
              name="title"
              placeholder='Title'
              value={this.state.title}
              onChange={this.handleChange}
            />
          </div>
          <div className="form-group">
            <label htmlFor="description">Add Description</label><br />
            <input
              type="text"
              id="description"
              name="description"
              placeholder='Description'
              value={this.state.description}
              onChange={this.handleChange}
            />
          </div>
          <div className="form-group">
            <button type="button" onClick={this.onSaveTodo}>Save</button>
          </div>
        </form>
      </div>
    );
  };
}

export default compose(
  observer,
  inject('todoStore'),
)(TodoForm);

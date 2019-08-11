import React, { Component } from 'react';
import { compose } from 'recompose';
import { observer, inject } from 'mobx-react';
import ConsoleModal from './ConsoleModal'
import { request, closeConsole } from '../helpers'
class TodoForm extends Component {
  constructor() {
    super()
    this.handleChange = this.handleChange.bind(this);
    this.onSaveTodo = this.onSaveTodo.bind(this);
    this.closeConsole = closeConsole.bind(this);
    this.state = {
      consoleMessage: '',
      link: {
        url: '',
        linkText: '',
      },
      todoObj: {
        title: '',
        description: '',
        links: [],
      },
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
    });
  };

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
      todoObj: {
        ...this.state.todoObj,
        links: [...this.state.todoObj.links, this.state.link],
      },
      link: {
        linkText: '',
        url: '',
      },
    });
  }

  removeLink(event, index) {
    event.preventDefault();
    this.state.todoObj.links.splice(index, 1);
    this.setState({
      ...this.state,
      todoObj: {
        ...this.state.todoObj,
        links: [...this.state.todoObj.links],
      },
    });
  }

  async onSaveTodo(event) {
    const todo = await request('/todos', 'POST', this.state.todoObj);
    if (todo.message) {
      console.log(todo.message);
      const { message } = todo;
      let errorMessage = message;
      if (message === 'duplicate entry for unique key title') {
        errorMessage = 'A todo with this title already exist'
      }
      this.setState({
        consoleMessage: errorMessage
      })
      return null
    }
    this.props.todoStore.addTodo(todo);

    // Reset state
    this.setState({
      todoObj: {
        title: '',
        description: '',
        links: [],
      },
    })
  };

  render() {
    let disableSubmit
    const {
      title,
      description,
      links
    } = this.state.todoObj;
    const { consoleMessage } = this.state;
    title && description ? disableSubmit = false : disableSubmit = true
    return (
      <div id="todo-form_container">
        {consoleMessage &&
          <ConsoleModal
            message={consoleMessage}
            closeConsole={this.closeConsole}
          />
        }
        <form>
          <div className="form-header">
            <h3>Add a Task to Complete</h3>
          </div>
          <div className="form-group">
            <label htmlFor="title">Add Title</label>
            <span className="requiredFields">*</span><br />
            <input
              type="text"
              id="title"
              name="title"
              placeholder='Title'
              value={title}
              onChange={this.handleChange}
            />
          </div>
          <div className="form-group">
            <label htmlFor="description">Add Description</label>
            <span className="requiredFields">*</span><br />
            <input
              type="text"
              id="description"
              name="description"
              placeholder='Description'
              value={description}
              onChange={this.handleChange}
            />
          </div>
          <div>{
            links.map((link, index) => {
              return (
                <span key={index}>
                  <button 
                    onClick={event => this.removeLink(event, index)}
                  >x
                  </button>
                  <a target="_blank" href={link.url}>{link.linkText || link.url}
                  </a><br />
                </span>
              );
            })
          }</div>
          <div className="form-group">
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
            </fieldset>
          </div>
          <div className="form-group">
            <button
              type="button"
              onClick={this.onSaveTodo}
              disabled={disableSubmit}
            >Save</button>
          </div>
        </form>
      </div>
    );
  };
}

export default compose(
  inject('todoStore'),
  observer,
)(TodoForm);

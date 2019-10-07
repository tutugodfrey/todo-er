import React, { Component } from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { withRouter } from 'react-router-dom';
import { request, closeConsole } from '../helpers';

import ConsoleModal from './ConsoleModal';


export class LoginInline extends Component {
  constructor() {
    super()
    this.closeConsole = closeConsole.bind(this)
    this.state = {
      consoleMessage: '',
      user: {
        username: '',
        password: '',
      }
    }
    this.onSignIn = this.onSignIn.bind(this);
    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(event) {
    const { name, value } = event.target;
    this.setState({
      ...this.state,
      user: {
        ...this.state.user,
        [name]: value
      }
    });
  }

  async onSignIn(event) {
    event.preventDefault();
    let allFieldPass = true;
    for(let field in this.state.user) {
      if (!this.state.user[field]) {
        allFieldPass = false;
      }
    }
    if (allFieldPass) {
      const createdUser =  await request('/users/signin', 'POST', this.state.user);
      if (createdUser.message) {
        const { message } = createdUser;
        let errorMessage = message;
        if (message === 'user not found') {
          errorMessage =
            'Unsuccessful login! Please check your username and password'
        }
        this.setState({
          consoleMessage: errorMessage,
        })
        console.log(createdUser.message)
        return null;
      }
      localStorage.setItem('token', createdUser.token)
      this.props.userStore.setUser(createdUser)  
      this.props.history.push('/dashboard')
    }
  }

  render() {
    let disableSubmit
    const { password, username } = this.state.user;
    const { consoleMessage } = this.state;
    !password || !username ? disableSubmit = true : disableSubmit = false;
    return (
      <div id="login-inline">
        {consoleMessage &&
          <ConsoleModal
            message={consoleMessage}
            closeConsole={this.closeConsole}
          />
        }
        <form>
          <div id="form-group_container">
            <div className="form-group">
              <input
                type="text"
                name="username"
                value={username}
                onChange={this.handleChange}
              />
            </div>
            <div className="form-group">
              <input 
                type="password"
                name="password"
                value={password}
                onChange={this.handleChange}
              />
            </div>
            <div className="form-group">
              <input
                type="submit"
                onClick={this.onSignIn}
                disabled={disableSubmit}
                value="Sign In"
              />
            </div>
          </div>
        </form>
      </div>
    );
  };
};

export default compose(
  inject('userStore'),
  observer,
  withRouter,
)(LoginInline);

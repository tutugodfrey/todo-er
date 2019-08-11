import React, { Component } from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { withRouter, Link } from 'react-router-dom';
import { request, closeConsole } from '../helpers';

import ConsoleModal from './ConsoleModal';


class Signin extends Component {
  constructor() {
    super()
    this.closeConsole = closeConsole.bind(this)
    this.state = {
      consoleMessage: 'jddjisdinjdsdidjnijdsvdvsbhifbhidfdhidisbh',
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
      <div>
        <div>
          <Link to="/">&laquo; Back</Link>
        </div>
        <div className="sign-in">
          {consoleMessage &&
            <ConsoleModal
              message={consoleMessage}
              closeConsole={this.closeConsole}
            />
          }
          <div>
            <h3>Sign In</h3>
          </div>
          <form>
            <div>
              <div className="form-group">
                <div><label>Username</label>
                  <span className="requiredFields">*</span>
                </div>
                <input
                  type="text"
                  name="username"
                  value={username}
                  onChange={this.handleChange}
                />
              </div>
            </div>
            <div className="form-group">
              <div><label>Password</label>
                <span className="requiredFields">*</span>
              </div>
              <div>
                <input 
                  type="password"
                  name="password"
                  value={password}
                  onChange={this.handleChange}
                  />
              </div>
            </div>
            <div className="form-group">
              <div>
                <input
                  type="submit"
                  onClick={this.onSignIn}
                  disabled={disableSubmit}
                  value="Sign In"
                />
              </div>
            </div>
          </form>
          <div>
            <p>I don't have an account!
              <Link to="/signup"> Sign Up</Link></p>
          </div>
        </div>
      </div>
    )
  }
}

export default compose(
  inject('userStore'),
  observer,
  withRouter,
)(Signin);

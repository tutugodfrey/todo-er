import React, { Component } from 'react';
import { withRouter, Link } from 'react-router-dom';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';

import ConsoleModal from './ConsoleModal';

import { request, closeConsole } from '../helpers';

  export class Signup extends Component  {
    constructor(props) {
      super(props);
      this.closeConsole = closeConsole.bind(this)
      this.state =  {
        consoleMessage: '',
        user: {
          name: '',
          email: '',
          username: '',
          password: '',
          confirmPassword: ''
        },
        createdUser: {},
      };
      this.handleChange = this.handleChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
    }
  
  
  
    handleChange(event) {
      // event.preventDefault();
      const { name, value } = event.target;
      this.setState({
        ...this.state,
        user: {
          ...this.state.user,
          [name]: value
        }
      });
    }

    async handleSubmit(event) {
      event.preventDefault();
      let allFieldPass = true;
      for(let field in this.state.user) {
        if (!this.state.user[field]) {
          console.log(field, this.state.user[field], 'missing value')
          allFieldPass = false;
        }
      }
      if (allFieldPass) {
        const createdUser =  await request('/users/signup', 'POST', this.state.user);
        if (createdUser.message) {
          let errorMessage = createdUser.message;
          if (errorMessage.indexOf('unique') >= 0) {
            errorMessage = 'User with detail you provide already exist'
          }
          this.setState({
            consoleMessage: errorMessage,
          });
          console.log(createdUser.message)
          return null;
        }

        localStorage.setItem('token', createdUser.token)
        this.props.userStore.setUser(createdUser)  
        this.props.history.push('/dashboard')
      }
    }
    render() {
      let disabled;
      const {
        name,
        email,
        username,
        password,
        confirmPassword
      } = this.state.user;
      const { consoleMessage } = this.state;
      !name ||
      !email ||
      !username ||
      !password ||
      !confirmPassword ? disabled = true : disabled = false;
      return (
        <div>
          <div>
            <Link to="/">&laquo; Back</Link>
          </div>
          <div className="sign-up">
            {consoleMessage &&
              <ConsoleModal
                message={consoleMessage}
                closeConsole={this.closeConsole}
              />
            }
            <form>
              <div>
                <h3>Sign Up</h3>
              </div>
              <div>
                <div className="form-group">
                  <div><label>Name</label>
                    <span className="requiredFields">*</span>
                  </div>
                  <div>
                    <input
                      type="text"
                      name="name"
                      placeholder="Full Name"
                      value={name}
                      onChange={this.handleChange.bind(this)}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <div><label>Email</label>
                    <span className="requiredFields">*</span>
                  </div>
                  <div>
                    <input 
                      type="text"
                      name="email"
                      placeholder="Email"
                      value={email}
                      onChange={this.handleChange}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <div><label>Username</label>
                    <span className="requiredFields">*</span>
                  </div>
                  <div>
                    <input
                      type="text"
                      name="username"
                      placeholder="Username"
                      value={username}
                      onChange={this.handleChange}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <div><label>password</label>
                    <span className="requiredFields">*</span>
                  </div>
                  <div>
                    <input
                      type="password"
                      name="password"
                      placeholder="Password"
                      value={password}
                      onChange={this.handleChange}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <div><label>Confirm Password</label>
                    <span className="requiredFields">*</span>
                  </div>
                  <div>
                    <input
                      type="password"
                      name="confirmPassword"
                      placeholder="Confirm"
                      value={confirmPassword}
                      onChange={this.handleChange}
                    />
                  </div>
                </div>
                <div>
                <div className="form-group">
                  <div>
                    <input
                      type="submit"
                      name="signup"
                      value="Sign Up"
                      id="submit-btn"
                      disabled={disabled}
                      onClick={this.handleSubmit}
                    />
                  </div>
                </div>
                </div>
              </div>
            </form>
            <div>
              <p>I already have an account! 
                <Link to="/signin"> Sign In here</Link></p>
            </div>
          </div>
        </div>
      )
    }
  }

export default compose(
  inject('userStore'),
  observer,
  withRouter
)(Signup);

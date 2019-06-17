import React, { Component } from 'react';
import { request } from '../helpers';
import { withRouter } from 'react-router-dom';
import UserContext from './userContext';
import Dashboard from './Dashboard.jsx';
import { observer } from 'mobx-react';
import { inject } from 'mobx-react';
import { compose } from 'recompose';

// @observer
// const signup = Component => {
  export class Signup extends Component  {
    constructor(props) {
      super(props);
      this.state =  {
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
      console.log(event)
      let allFieldPass = true;
      for(let field in this.state.user) {
        if (!this.state.user[field]) {
          console.log(field, this.state.user[field], 'missing value')
          allFieldPass = false;
        }
      }
      if (allFieldPass) {
        const createdUser =  await request('/api/users/signup', 'POST', this.state.user)
        this.setState({
          createdUser,
        });
        // console.log(createdUser, 'BBBBBBBB')
        // console.log(res, 'AAAAAAA')      
        // this.props.history.push('/dashboard')
      }
    }
    render() {
      const { createdUser } = this.state;
      if (createdUser.username) {
        return (
          <UserContext.Provider value={createdUser}>
            <Dashboard />
          </UserContext.Provider>
        )
      }
      return (
        <div className="container">
          <form>
            <div>
              <h3>Signup</h3>
            </div>
            <div>
              <div>
                <div><label>Name</label></div>
                <div>
                  <input
                    type="text"
                    name="name"
                    defaultValue={this.state.user.name}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
              <div>
                <div><label>Email</label></div>
                <div>
                  <input 
                    type="text"
                    name="email"
                    defaultValue={this.state.user.email}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
              <div>
                <div><label>Username</label></div>
                <div>
                  <input
                    type="text"
                    name="username"
                    defaultValue={this.state.user.username}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
              <div>
                <div><label>password</label></div>
                <div>
                  <input
                    type="password"
                    name="password"
                    defaultValue={this.state.user.password}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
              <div>
                <div><label>passsword</label></div>
                <div>
                  <input
                    type="password"
                    name="confirmPassword"
                    defaultValue={this.state.user.confirmPassword}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
              <div>
                <div>
                  <input
                    type="submit"
                    name="signup"
                    value="Sign Up"
                    id="submit-btn"
                    onClick={this.handleSubmit}
                    />
                  </div>
              </div>
            </div>
          </form>
        </div>
      )
    }
  }
//   return compose(
//     inject('store'),
//   )(Signup);
// }


export default withRouter(Signup);
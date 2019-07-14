import React, { Component } from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { withRouter, Link } from 'react-router-dom';
import { request } from '../helpers';


class Signin extends Component {
  constructor() {
    super()
    this.state = {
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
        console.log(field, this.state.user[field], 'missing value')
        allFieldPass = false;
      }
    }
    if (allFieldPass) {
      const createdUser =  await request('/users/signin', 'POST', this.state.user)
      localStorage.setItem('token', createdUser.token)
      this.props.userStore.setUser(createdUser)  
      this.props.history.push('/dashboard')
    }
  }
  render() {
    return (
      <div>
        <form>
          <div>
            <label>Username</label>
            <input type="text" name="username" value={this.state.username} onChange={this.handleChange} />
          </div>
          <div>
            <label>password</label>
            <input type="password" name="password" value={this.state.password} onChange={this.handleChange} />
          </div>
          <div>
            <button onClick={this.onSignIn}>Sign In</button>
          </div>
        </form>
        <p>I don't have an account! <Link to="/signup">Sign Up</Link></p>
      </div>
    )
  }
}

export default compose(
  observer,
  inject('userStore'),
  withRouter,
)(Signin);

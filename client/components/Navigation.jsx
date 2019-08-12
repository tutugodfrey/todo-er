import React, { Component } from 'react'
import { Link, withRouter } from 'react-router-dom';

class Navigation extends Component {
  logout() {
    localStorage.clear();
    return this.props.history.push('/signin')
  }

  render() {
    return (
      <div id="nav-bar">
        <div id="profile">
          <Link to='./profile'>Profile</Link>
        </div>
        <div id="logout">
          <a onClick={this.logout.bind(this)}>Log Out</a>
        </div>
      </div>
    );
  }
}

export default withRouter(Navigation);

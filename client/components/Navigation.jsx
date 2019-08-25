import React, { Component, Fragment } from 'react'
import { Link, withRouter } from 'react-router-dom';

class Navigation extends Component {
  logout() {
    localStorage.clear();
    return this.props.history.push('/signin')
  }

  render() {
    const isLoggedIn = !!localStorage.getItem('token')
    return (
      <div id="nav-bar">
        {isLoggedIn ? (
          <Fragment>
            <div id="profile">
              <Link to='/'>Home</Link>
            </div>
            <div id="profile">
              <Link to='./dashboard'>Tasks</Link>
            </div>
            <div id="profile">
              <Link to='./profile'>Profile</Link>
            </div>
            <div id="logout">
              <a onClick={this.logout.bind(this)}>Log Out</a>
            </div>
          </Fragment>
        ) : (
          <Fragment>
            <div id="signin"><Link to="/signin">Sign In</Link></div>
            <div id="signup"><Link to='/signup'>Sign Up</Link></div>
          </Fragment>
        )}
      </div>
    );
  }
}

export default withRouter(Navigation);

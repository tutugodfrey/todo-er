import React from 'react';
import { Redirect } from 'react-router-dom';
import Todo from './Todo.jsx'
import Navigation from './Navigation.jsx'
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { logout } from '../helpers'

class Dashboard extends React.Component {
  render() {
    // const user = this.props.userStore.getUser;
    const isLoggedIn = !!localStorage.getItem('token');
    return (
      <div>
        {!isLoggedIn && 
          <Redirect to="/signin" />
        }
        <Navigation logout={logout} />
        <Todo />
      </div>
    );
  }
}

export default compose(
  inject('userStore'),
  observer,
)(Dashboard);

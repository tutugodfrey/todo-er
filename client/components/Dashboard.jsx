import React from 'react'
import UserContext from './userContext';
import Profile from './Profile.jsx';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';

class Dashboard extends React.Component {
  render() {
    // const user = this.props.userStore.getUser;
    return (
      <div>
        <Profile />
      </div>
    );
  }
}

export default compose(
  inject('userStore'),
  observer,
)(Dashboard);

import React from 'react'
import UserContext from './userContext';
import Profile from './Profile.jsx';

class Dashboard extends React.Component {
  render() {
    const { createdUser } = this.context;
    return (
      <div>
        <Profile user={createdUser}/>
      </div>
    );
  }
}

export default Dashboard;

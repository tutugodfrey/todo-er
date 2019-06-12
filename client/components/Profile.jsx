import React from 'react';
import UserContext from './userContext';

class Profile extends React.Component {
  static contextType = UserContext
  render() {
    const user = this.context
    // const { user } = this.props
    console.log(user)
    return (
        <div>{user.username}</div>
      );
  }
}
Profile.contextType = UserContext
export default Profile;

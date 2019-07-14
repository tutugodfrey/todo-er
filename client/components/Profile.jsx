import React from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';

import { request } from '../helpers';

class Profile extends React.Component {
  constructor() {
    super();
    this.state = {
      editMode: false,
      editUser: {},
    }
    this.editMode = this.editMode.bind(this);
    this.onEditText = this.onEditText.bind(this);
    this.onSaveUpdate = this.onSaveUpdate.bind(this);
  }

  componentWillMount() {
    this.setState({
      ...this.state,
      user: this.props.userStore.getUser,
      editUser: this.props.userStore.getUser,
    })
  }
  onEditText(event) {
    const { name, value } = event.target;
    this.setState({
      ...this.state,
      editUser: {
        ...this.state.editUser,
        [name]: value
      }
    })
  }
  editMode(event) {
    this.setState({
      ...this.state,
      editMode: true
    })
  }

  async onSaveUpdate(event) {
    const updatedUser = await request('/users', 'PUT', this.state.editUser);
    this.props.userStore.setUser(updatedUser);
    this.setState({
      ...this.state,
      editMode: false,
    })
  }
  render() {
    const user = this.props.userStore.getUser;
    const { name, email } = this.state.editUser
    return (
      <div>
        {this.state.editMode && (
          <div>
            <div>
              <label>Name:</label>
              <input
                type="text"
                name="name"
                value={name}
                onChange={this.onEditText}
              />
            </div>
            <div>
              <label>Email:</label>
              <input
                type="text"
                name="email"
                value={email}
                onChange={this.onEditText}
              />
            </div>
            <div><button onClick={this.onSaveUpdate}>Save</button></div>
          </div>
        )}
        {!this.state.editMode && (
          <div>
            <ul>
              <li><strong>Name:</strong><span>{user.name}</span></li>
              <li><strong>Email:</strong><span>{user.email}</span></li>
              <li><strong>Username:</strong><span>{user.username}</span></li>
            </ul>
            <button type="button" onClick={this.editMode}>Edit</button>
          </div>
        )}
      </div>
    );
  }
}
export default compose(
  inject('userStore'),
  observer,
)(Profile);

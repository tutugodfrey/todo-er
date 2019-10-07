import React from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { Link } from 'react-router-dom';
import { request } from '../helpers';
import Navigation from './Navigation'

export class Profile extends React.Component {
  constructor() {
    super();
    this.state = {
      editMode: false,
      editUser: {},
    }
    this.toggleEditMode = this.toggleEditMode.bind(this);
    this.onEditText = this.onEditText.bind(this);
    this.onSaveUpdate = this.onSaveUpdate.bind(this);
  }

  async componentWillMount() {
    const user = this.props.userStore.getUser;
    if (!Object.keys(user).length) {
      const getUser = await request('/user', 'GET');
      this.props.userStore.setUser(getUser);
    }
    this.setState({
      ...this.state,
      user,
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
  toggleEditMode(event) {
    this.setState({
      ...this.state,
      editMode: !this.state.editMode,
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
        <Navigation />
        <div className="back-link_div">
          <Link to="/dashboard">&laquo; Back</Link>
        </div>
        <div id="profile-page">
          {this.state.editMode && (
            <div id="edit-profile">
              <div className="profile-image_div">
                <img src={user.imgUrl || "public/default-profile.png"}/>
              </div>
              <div className="input-group">
                <label>Name:</label>
                <input
                  type="text"
                  name="name"
                  value={name}
                  onChange={this.onEditText}
                />
              </div>
              <div className="input-group">
                <label>Email:</label>
                <input
                  type="text"
                  name="email"
                  value={email}
                  onChange={this.onEditText}
                />
              </div>
              <div id="btn-group">
                <div>
                  <button type="button" id="save-edit" onClick={this.onSaveUpdate}
                  >Save</button>
                </div>
                <div>
                  <button type="button" id="cancel-edit" onClick={this.toggleEditMode}
                  >Cancel</button>
                </div>
              </div>
            </div>
          )}
          {!this.state.editMode && (
            <div id="profile-info">
              <div id="profile-header_div">
                <h3>{user.name}</h3>
              </div>
              <div className="profile-image_div" id="profile-image_div">
                <img src={user.imgUser || 'public/default-profile.png'} />
              </div>
              <div className="profile-details">
                <div><strong>Email:</strong></div>
                <div><span>{user.email}</span></div>
              </div>
              <div className="profile-details">
                <div><strong>Username:</strong></div>
                <div><span>{user.username}</span></div>
              </div>
              <div id="edit-profile-btn_div">
                <button
                type="button"
                onClick={this.toggleEditMode}
                >Edit</button>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }
}
export default compose(
  inject('userStore'),
  observer,
)(Profile);

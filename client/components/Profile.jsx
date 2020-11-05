import React, { Fragment } from 'react';
import { observer, inject } from 'mobx-react';
import { compose } from 'recompose';
import { Link } from 'react-router-dom';
import { request } from '../helpers';
import Navigation from './Navigation';
import path from 'path';

export class Profile extends React.Component {
  constructor() {
    super();
    this.state = {
      editMode: false,
      editUser: {},
      changeProfileImage: false,
      photoLoaded: false,
      photoUploadCompleted: false,
      profileImage: '',
      imageObj: {},
    }
    this.toggleEditMode = this.toggleEditMode.bind(this);
    this.onEditText = this.onEditText.bind(this);
    this.onSaveUpdate = this.onSaveUpdate.bind(this);
    this.toggleChangeImageMode = this.toggleChangeImageMode.bind(this);
    this.handlePhotoPreview = this.handlePhotoPreview.bind(this);
    this.uploadPhoto = this.uploadPhoto.bind(this);
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

  toggleChangeImageMode(event) {
    this.setState({
      ...this.state,
      changeProfileImage: !this.state.changeProfileImage,
    });
    const isPhotoLoaded = this.state.photoLoaded;
    if (isPhotoLoaded) {
      this.setState({
        photoLoaded: false,
        imageObj: {},
        profileImage: '',
      });
      if (this.state.profileImage) {
        URL.revokeObjectURL(this.state.profileImage)
      }
    }
  }

  async handlePhotoPreview(event) {
    const image =  event.target.files[0];
    if (this.state.profileImage) {
      URL.revokeObjectURL(this.state.profileImage)
    }
    const url = URL.createObjectURL(image)
    this.setState({
      profileImage: url,
      photoLoaded: true,
      imageObj: image,
    });
  }

  async uploadPhoto(event) {
    const formData = new FormData();
    formData.append('profilePhoto', this.state.imageObj);
    const res = await request('/users/photo', 'POST', formData);
    if (res.name) {
      this.props.userStore.setUser(res);
      this.setState({
        ...this.state,
        photoUploadCompleted: true,
        photoLoaded: false,
        changeProfileImage: false,
      });

      setTimeout(() => {
        this.setState({
          ...this.state,
          photoUploadCompleted: false,
        });
      }, 5000)
    }
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
    const { imgUrl } = user;
    const { name, email } = this.state.editUser;
    const { changeProfileImage, photoLoaded, photoUploadCompleted } = this.state;
    const changeProfileBtnColor = changeProfileImage ? 'red': 'dark';
    const showUploadBtn = photoLoaded ? 'show' : 'hide';
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
                <img src={imgUrl || "public/profilePhotos/default-profile.png"}/>
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
                {photoUploadCompleted && 
                <span
                  id="profile-photo-save-success"
                  className="pop-up">Profile picture have been saved!
                </span>}
                <Fragment>
                  <img
                    src={ this.state.profileImage || imgUrl || 'public/profilePhotos/default-profile.png'}
                  />
                  <br />
                </Fragment>
                {photoLoaded &&
                  <button
                    className={showUploadBtn}
                    onClick={this.uploadPhoto}>Upload
                  </button>}
                <br />
                {changeProfileImage && 
                  <Fragment>
                    <input
                      type='file'
                      name='profile-photo'
                      onChange={this.handlePhotoPreview}
                    />
                    <br />
                  </Fragment>}
                <button
                  id="change-profile-photo"
                  className={changeProfileBtnColor}
                  onClick={this.toggleChangeImageMode}
                >
                  {changeProfileImage? "Cancle" : "Change"}
                </button>
                <img src={user.imgUser || 'public/profilePhotos/default-profile.png'} />
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
                >
                  Edit
                </button>
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

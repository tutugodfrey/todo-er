import React from 'react';
import { Profile } from '../../../components/Profile';
import { testUsers } from '../../../../helpers';

const { user1 } = testUsers
const userStore = {
  setUser: jest.fn(),
  getUser: user1
}
let wrapper;
fetch.mockResponseOnce(JSON.stringify({
  ...user1
 }))
describe('Profile component test', () => {
  beforeAll(() => {
    wrapper = shallow(<Profile userStore={userStore}/>);
  });
  describe('General', () => {
    test('should find parent div', () => {
      const children = wrapper.children();
      expect(wrapper.name()).toBe('div');
      expect(children.length).toBe(3)
      expect(children.first().name()).toBe('withRouter(Navigation)');
      expect(children.at(1).name()).toBe('div');
      expect(children.last().name()).toBe('div');
    });

    test('should Back link', () => {
      expect(wrapper.find('.back-link_div').name()).toBe('div');
      expect(wrapper.find('Link').props().to).toEqual('/dashboard');
      expect(wrapper.find('Link').props()
        .children).toEqual(expect.stringContaining('Back'));
    });

    test('should find Navigation component', () => {
      const nav = wrapper.find('withRouter(Navigation)');
      expect(nav.length).toBe(1)
    });

    test('should find profile page', () => {
      const profileDiv = wrapper.find('[id="profile-page"]');
      expect(profileDiv.type()).toBe('div');
    });
  });

  describe('Edit mode off', () => {
    let profileInfo
    let childrenInfo
    beforeAll(() => {
      profileInfo = wrapper.find('[id="profile-info"]');
      childrenInfo = profileInfo.children();
    })

    test('should render all info', () => {
      expect(childrenInfo.length).toEqual(5);
    });

    test('should render profile header', () => {
      expect(childrenInfo.at(0).props().id).toBe('profile-header_div');
      expect(childrenInfo.at(0).name()).toBe('div');
      expect(childrenInfo.at(0).children().type()).toBe('h3');
      expect(childrenInfo.at(0).children().text()).toBe(user1.name);
    });

    test('should render image', () => {
      expect(childrenInfo.at(1).props().id).toBe('profile-image_div');
      expect(childrenInfo.at(1).name()).toBe('div');
      expect(childrenInfo.at(1).children().at(0).type()).toBe('img');
      expect(childrenInfo.at(1).children().at(0).props().src).toBe('public/profilePhotos/default-profile.png');
      expect(childrenInfo.at(1).children().at(3).name()).toBe('button');
      expect(childrenInfo.at(1).children().at(3).props().children).toBe('Change');
      wrapper.find('#change-profile-photo').simulate('click');
      expect(wrapper.find('#profile-image_div').children().at(3).type()).toBe('input')
      expect(wrapper.find('#profile-image_div').children().at(3).props().type).toBe('file')
      expect(wrapper.find('#profile-image_div').children().at(5).type()).toBe('button')
      expect(wrapper.find('#profile-image_div').children().at(5).text()).toBe('Cancle')
    });

    test('should render email', () => {
      expect(childrenInfo.at(2).props().className).toBe('profile-details');
      expect(childrenInfo.at(2).name()).toBe('div');
      expect(childrenInfo.at(2).children().length).toBe(2);
      expect(childrenInfo.at(2).childAt(0).children().props().children).toBe('Email:');
      expect(childrenInfo.at(2).childAt(1).children().props().children).toBe(user1.email);
    });

    test('should rener username', () => {
      expect(childrenInfo.at(3).props().className).toBe('profile-details');
      expect(childrenInfo.at(3).name()).toBe('div');
      expect(childrenInfo.at(3).children().length).toBe(2);
      expect(childrenInfo.at(3).childAt(0).children().props().children).toBe('Username:');
      expect(childrenInfo.at(3).childAt(1).children().props().children).toBe(user1.username);
    });

    test('should find Edit button', () => {
      expect(childrenInfo.at(4).props().id).toBe('edit-profile-btn_div');
      expect(childrenInfo.at(4).name()).toBe('div');
      expect(childrenInfo.at(4).children().type()).toBe('button');
      expect(childrenInfo.at(4).children().props().children).toBe('Edit');
    });
  });

  describe('Edit mode on', () => {
    let editProfile;
    let children;
    beforeAll(() => {
      wrapper.setState({ editMode: true });
      editProfile = wrapper.find('#edit-profile');
      children = editProfile.children();
    });

    test('should find edit-profile', () => {
      expect(editProfile.name()).toBe('div');
      expect(children.length).toBe(4)
    });

    test('should render image', () => {
      expect(children.at(0).props().className).toBe('profile-image_div');
      expect(children.at(0).name()).toBe('div');
      expect(children.at(0).children().type()).toBe('img');
      expect(children.at(0).children().props().src).toBe('public/profilePhotos/default-profile.png');
    });

    test('should render name for editing', () => {
      expect(children.at(1).props().className).toBe('input-group');
      expect(children.at(1).children().length).toBe(2);
      expect(children.at(1).childAt(0).type()).toBe('label');
      expect(children.at(1).childAt(1).type()).toBe('input');
      expect(children.at(1).childAt(1).props().name).toBe('name');
      expect(children.at(1).childAt(1).props().type).toBe('text');
      expect(children.at(1).childAt(1).props().value).toBe(user1.name);
    });

    test('should render email for editing', () => {
      expect(children.at(2).props().className).toBe('input-group');
      expect(children.at(2).children().length).toBe(2);
      expect(children.at(2).childAt(0).type()).toBe('label');
      expect(children.at(2).childAt(1).type()).toBe('input');
      expect(children.at(2).childAt(1).props().name).toBe('email');
      expect(children.at(2).childAt(1).props().type).toBe('text');
      expect(children.at(2).childAt(1).props().value).toBe(user1.email);
    });

    test('should display Save and Cancel buttons', () => {
      expect(children.at(3).props().id).toBe('btn-group');
      expect(children.at(3).children().children().length).toBe(2);
      expect(children.at(3).childAt(0).children().text()).toBe('Save');
      expect(children.at(3).childAt(0).children().type()).toBe('button');
      expect(children.at(3).childAt(0).children().props().id).toBe('save-edit');
      expect(children.at(3).childAt(1).children().text()).toBe('Cancel');
      expect(children.at(3).childAt(1).children().type()).toBe('button');
      expect(children.at(3).childAt(1).children().props().id).toBe('cancel-edit');
    });
  });
});

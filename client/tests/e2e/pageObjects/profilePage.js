import selectors from './selectors';
import Base from './base';
import { testUsers } from '../../../../helpers';

const base = Base();
const { dashboard, profile } = selectors;
const { editUser1 } = testUsers;

export default {
  navToProfile: async () => {
    await base.find(dashboard.profileLink).click();
    await base.waitUntilPageLoad('/profile');
    const name = await base.find(profile.profileHeader).getText();
    const emailKey = await base.find(profile.emailKey).getText();
    const emailValue = await base.find(profile.emailValue).getText();
    const usernameKey = await base.find(profile.usernameKey).getText();
    const usernameValue = await base.find(profile.usernameValue).getText();
    const details = {
      name,
      [emailKey.substring(0, emailKey.length - 1).toLowerCase()]: emailValue,
      [usernameKey.substring(0, usernameKey.length - 1).toLowerCase()]: usernameValue,
    }
    return details;
  },
  editProfileAndCancel: async () => {
    const editProfileBtn = await base.find(profile.editProfileBtn);
    const editBtnName = await editProfileBtn.getText();
    await editProfileBtn.click();
    await base.find(profile.editProfileInputName).clear();
    await base.write(profile.editProfileInputName, editUser1.name);
    await base.find(profile.editProfileInputEmail).clear();
    await base.write(profile.editProfileInputEmail, editUser1.email);
    const cancelBtn = await base.find(profile.cancelEditBtn);
    const cancelBtnName = await cancelBtn.getText();
    await cancelBtn.click();
    return {
      editBtnName,
      cancelBtnName,
    }
  },
  editProfileAndSave: async () => {
    const editProfileBtn = await base.find(profile.editProfileBtn);
    await editProfileBtn.click();
    await base.find(profile.editProfileInputName).clear();
    await base.write(profile.editProfileInputName, editUser1.name);
    await base.find(profile.editProfileInputEmail).clear();
    await base.write(profile.editProfileInputEmail, editUser1.email);
    const saveBtn = await base.find(profile.saveEditBtn);
    const saveBtnName = await saveBtn.getText();
    await saveBtn.click()
    return {
      saveBtnName
    }
  }
}

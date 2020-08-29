import { suite } from 'selenium-webdriver/testing';
import chaiAsPromised from 'chai-as-promised';
import chai from 'chai';
import dotenv from 'dotenv-safe';
import Base from './pageObjects/base';
import { testUsers } from '../../../helpers';
import {
  landingPage,
  signupPage,
  signinPage,
  dashboard,
  profilePage,
} from './pageObjects';
import uploadImage from '../../../src/middlewares/fileupload';

dotenv.config();
const { expect } = chai;
chai.use(chaiAsPromised)
const { user1, editUser1 } = testUsers;
const base = Base();
let landing;
let { WEB_URL } = process.env;
WEB_URL = WEB_URL || 'http://localhost:3005'
describe('Integration testing', () => {
    before(async () => {
      base.visit(WEB_URL);
      base.driver.manage().window().maximize();
    });

    after(async () => {
      await base.driver.sleep(1000);
      await base.quit();
    });

    it('shoulld tests something', async () => {
      landing = await landingPage.pageElements();
      expect(landing.signin).to.eventually.equal('Sign In')
      expect(landing.signup).to.eventually.equal('Sign Up');
      expect(landing.story).to.eventually.equal('Task marker let you keep track of your goals for the day');
      expect(landing.header).to.eventually.equal('Don\'t leave any task uncompleted!');
      return expect(landing.submitBtnText).to.eventually.equal('Sign In');
    }).timeout(10000);

    it('should attempt to signin', async () => {
      await signinPage.inLineSignin('username', 'Aa!12345');
      const consoleModalText = await base.checkConsoleModal();
      await base.closeConsoleModal();
      return expect(consoleModalText).to.equal('Unsuccessful login! Please check your username and password');
    });

    it('should go to signup page', () => {
      return signupPage.signUp();
    });

    it('should test dashboard', async () => {
      const dashboardPage = await dashboard.scanningPage();
      expect(dashboardPage.homeLink).to.equal('Home');
      expect(dashboardPage.tasksLink).to.equal('Tasks');
      expect(dashboardPage.profileLink).to.equal('Profile');
      expect(dashboardPage.logoutLink).to.equal('Log Out');
      expect(dashboardPage.formHeader).to.equal('Add a Task to Complete');
      expect(dashboardPage.contentHeader).to.equal('No Todos! Start adding your tasks');
      const createTask = await dashboard.createTask();
      expect(createTask.contentHeader).to.equal('Your Todos');
      return expect(createTask.taskTitle).to.equal('todo1 title');
    }).timeout(12000);

    it('should check todo expanded card', async () => {
      const taskContentCard = await dashboard.taskContentCard();
      const deadline = taskContentCard.deadline.split(' ');
      expect(taskContentCard.taskTitle).to.equal('todo1 title');

      // Test to create task picked Thurday 
      expect(deadline[0]).to.equal('Thu');

      // Test to create task pick a deadline one year ahead of current year.
      expect(parseInt(deadline[3], 10)).to.equal(parseInt(new Date().toString().split(' ')[3], 10)+1)
      expect(taskContentCard.completed).to.eql('true');
      return expect(taskContentCard.taskDescription).to.equal('todo1 description');
    }).timeout(12000);

    it('should test profile page', async () => {
      const profile = await profilePage.navToProfile();
      expect(profile.name).to.equal(user1.name);
      expect(profile.username).to.equal(user1.username);
      expect(profile.email).to.equal(user1.email);
    });

    it('should edit user profile and cancel', async () => {
      const editProfile = await profilePage.editProfileAndCancel();
      expect(editProfile.editBtnName).to.equal('Edit');
      expect(editProfile.cancelBtnName).to.equal('Cancel');
    });

    it('should edit user profile and save', async () => {
      const editProfile = await profilePage.editProfileAndSave();
      const profile = await profilePage.navToProfile();
      expect(editProfile.saveBtnName).to.equal('Save');
      expect(profile.name).to.equal(editUser1.name);
      expect(profile.username).to.equal(user1.username);
      expect(profile.email).to.equal(editUser1.email);
      const res = await profilePage.changeProfilePhoto();
      expect(res).to.equal(null);
    });

    it('should logout user', () => {
      return dashboard.logOut();
    });

    it('should log user in', async () => {
      const signin = await signinPage.signin();
      expect(signin.signinFormHeader).to.equal('Sign In');
    });

    it('should logout user', async () => {
      await base.waitUntilPageLoad('/dashboard');
      await dashboard.logOut();
      return base.back();
    });

    it('should signin using inline login', async () => {
      await base.waitUntilHomePageLoad()
      return signinPage.inLineSignin(user1.username, user1.password);
    });
});

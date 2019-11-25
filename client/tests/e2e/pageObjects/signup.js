import selectors from './selectors';
import Base from './base';
import { testUsers } from '../../../../helpers';

const base = Base();
const By = base.By;
const until = base.until;
const { user1 }  = testUsers;
export default {
  signUp: async () => {
    const { signupPage } = selectors;
    base.find(selectors.landingPage.signup).click();
    await base.driver.wait(until.urlContains('/signup'), 5000);
    await base.driver.wait(until.elementLocated(By.css('div div h3')), 7000)
    base.write(signupPage.name, user1.name);
    base.write(signupPage.username, user1.username);
    base.write(signupPage.email, user1.email);
    base.write(signupPage.password1, user1.password);
    base.write(signupPage.password2, user1.confirmPassword);
    const signUpBtn = await base.find(signupPage.signUpBtn)
    await base.driver.wait(until.elementIsEnabled(signUpBtn), 5000)
    signUpBtn.click();
  }
};

import selectors from './selectors';
import Base from './base';

const base = Base();
const By = base.By;
const until = base.until;
export default {
  pageElements: async () => {
    const elements = {
      header: base.find(selectors.landingPage.header),
      signin: base.find(selectors.landingPage.signin),
      signup: base.find(selectors.landingPage.signup),
      story: base.find(selectors.landingPage.story),
      username: base.find(selectors.landingPage.username),
      password: base.find(selectors.landingPage.password),
      submitBtn: base.find(selectors.landingPage.loginBtn),
    };
    return {
      elements,
      header: elements.header.getText(),
      signin: elements.signin.getText(),
      signup: elements.signup.getText(),
      story: elements.story.getText(),
      username: elements.username.getText(),
      password: elements.password.getText(),
      submitBtnText: elements.submitBtn.getAttribute('value'),
    }
  },
}

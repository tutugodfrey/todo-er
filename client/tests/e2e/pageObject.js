import webdriver from 'selenium-webdriver';
import testUser from '../../../helpers/testUsers';

const { By, until } = webdriver;
const { user2 } = testUser;

export default (driver) => {
    const elements = {
    signupLink: By.xpath('//div/a[@href="/signup"]'),
    name: By.xpath('//div/input[@type="text" and @name="name"]'),
    username: By.xpath('//div/input[@type="text" and @name="username"]'),
    email: By.xpath('//div/input[@type="text" and @name="email"]'),
    password1: By.xpath('//div/input[@type="password" and @name="password"]'),
    password2: By.xpath('//div/input[@type="password" and @name="confirmPassword"]'),
    signUpBtn: By.xpath('//div/input[@type="submit" and @name="signup"]'),
  };
  return {
    elements,
    signUp: () => {
      driver.wait(until.elementLocated(elements.name));
      driver.findElement(elements.name).sendKeys(user2.fullname);
      driver.findElement(elements.username).sendKeys(user2.username);
      driver.findElement(elements.email).sendKeys(user2.email);
      driver.findElement(elements.password1).sendKeys(user2.password1);
      driver.findElement(elements.password2).sendKeys(user2.password2);
      return driver.findElement(elements.signUpBtn).click();
    },
  }
};

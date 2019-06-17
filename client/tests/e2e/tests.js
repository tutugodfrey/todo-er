import webdriver from 'selenium-webdriver';
import chaiAsPromised from 'chai-as-promised';
import chai from 'chai';
import mocha from 'mocha';

import pageObject from './pageObject';

chai.use(chaiAsPromised)
const {
  it, describe, before, after,
} = mocha;

let pageObj;
const { expect } = chai;
const { By, until } = webdriver
let elements;
const driver = new webdriver.Builder()
  .forBrowser('chrome')
  .build();


  describe('Integration testing', () => {
    before(() => {
      driver.get('http://localhost:3005');
      driver.manage().setTimeouts({ implicit: 30000, pageLoad: 30000 });
      driver.manage().window().maximize();
      pageObj = pageObject(driver);
      elements = pageObj.elements;
    });

  // after(() => {
  //   // close driver after test have finish running
  //   driver.close();
  // });

  describe('Scan through the landing page', () => {
    it('get elements on the home page', () => {
      driver.findElement(By.xpath('//div/h1')).getText()
        .then(value => {
        return expect(value).to.equal('Don\'t leave any task uncompleted!')
      });
      driver.wait(until.elementLocated(elements.signupLink));
      return driver.findElement(elements.signupLink).click()
    });
  });

  describe('Signup', () => {
    it('should confirm user signup', () => {
      return pageObj.signUp();
    });

    it('should redirect to home after signup success', () => {
      driver.wait(until.elementLocated(By.xpath('//div/a[@href="/signup"]', 10000)))
      return driver.getCurrentUrl()
        .then(currentUrl => {
          expect(currentUrl).to.equal('http://localhost:3005/signup')
        })
    })
  });
});

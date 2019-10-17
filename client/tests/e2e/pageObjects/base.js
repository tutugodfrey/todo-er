import 'chromedriver';
import webdriver from 'selenium-webdriver';
import selectors from './selectors';
const { By, until } = webdriver
const driver = new webdriver.Builder()
  .forBrowser('chrome')
  .build();

export default () => {
  return {
    driver,
    By,
    until,
    visit: (url) => {
      return driver.get(url);
    },
    quit: () => {
      return driver.quit();
    },
    back: () => {
      driver.wait(until.elementLocated(selectors.backLink), 20000);
      driver.findElement(selectors.backLink).click();
    },
    checkConsoleModal: () => {

    },
    wait: (condition, duration=5000) => {
      driver.wait(condition, duration)
    },
    waitUntilVisible: (element, duration=5000) => {
      return driver.wait(until.elementIsVisible(element), duration)
    },
    waitUntilHomePageLoad: async () => {
      return driver.wait(async () => {
        const url = await driver.getCurrentUrl();
        if (url.substring(url.length -1) === '/') return true
      }, 10000)
    },
    waitUntilUrlIs: (url) => {
      return driver.wait(until.urlContains(url), 5000);
    },
    waitUntilPageLoad: (urlSubstring) => {
      return driver.wait(until.urlContains(urlSubstring), 5000);
    },
    find: (selector) => {
      driver.wait(until.elementLocated(selector), 20000);
      return driver.findElement(selector);
    },
    write: (selector, text) => {
      driver.wait(until.elementLocated(selector), 5000);
      return driver.findElement(selector).sendKeys(text);
    },
    checkConsoleModal: async () => {
      await driver.wait(until.elementLocated(By.css("#console-modal")), 2000)
      const consoleModal = await driver.findElement(By.css("#console-modal p"))
      return  await consoleModal.getText();
    },
    closeConsoleModal: async () => {
      await driver.findElement(selectors.closeConsoleModalBtn).click()
    },

  }
}

import selectors from './selectors';
import Base from './base';
import { testTodos } from '../../../../helpers';

const base = Base();
const By = base.By;
const until = base.until;
const { todo1 } = testTodos;
const {
  dashboard: elements,
  taskForm: fields,
  tasksContainer,
  taskExpandedCard,
} = selectors;

export default {
  scanningPage: async () => {
    await base.driver.wait(until.urlContains('/dashboard'), 10000);
    await base.driver.wait(until.elementLocated(elements.taskFormHeader));
    await base.find(elements.homeLink).click();
    await base.find(elements.tasksLink).click();
    await base.find(elements.profileLink).click();
    await base.find(elements.tasksLink).click();
    const logoutLink = await base.find(elements.logoutLink).getText();

    const homeLink = await base.find(elements.homeLink).getText();
    const tasksLink = await base.find(elements.tasksLink).getText();
    const profileLink = await base.find(elements.profileLink).getText();
    const formHeader = await base.find(elements.taskFormHeader).getText();
    const contentHeader = await base.find(elements.taskContentHeader).getText();
    return {
      homeLink,
      tasksLink,
      profileLink,
      logoutLink,
      formHeader,
      contentHeader,
    }
  },
  createTask: async (num=1) => {
    await base.write(fields.titleInput, testTodos[`todo${num}`].title);
    await base.write(fields.descriptionInput, testTodos[`todo${num}`].description);
    await base.write(fields.linkDescriptionInput, testTodos[`todo${num}`].links[1].linkText);
    await base.write(fields.linkUrlInput, testTodos[`todo${num}`].links[1].url);
    await base.find(fields.addLinkBtn).click();
    // await base.driver.sleep(1000)
    await (await base.find(fields.addDeadlineBtn)).click();
    await base.driver.sleep(100);
    await base.find(fields.moveYearForwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.moveYearForwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.moveYearBackwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.moveMonthForwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.moveMonthForwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.moveMonthBackwardBtn).click();
    await base.driver.sleep(100);
    await base.find(fields.daySelector(4, 5)).click();
    await base.driver.sleep(100);
    await base.find(fields.saveTaskBtn).click();
    const contentHeader = await base.find(elements.taskContentHeader).getText();
    const taskTitle = await base.find(tasksContainer.createdTodoTitle).getText();
    const toggleTaskBtn = await base.find(tasksContainer.toggleTaskDisplayBtn);
    toggleTaskBtn.click();
    toggleTaskBtn.click();
    toggleTaskBtn.click();
    return {
      contentHeader,
      taskTitle,
      toggleTaskBtnText: await toggleTaskBtn.getText(),
    }
  },
  taskContentCard: async () => {
    await base.find(taskExpandedCard.completedCheckbox).click();
    await base.find(taskExpandedCard.completedCheckbox).click();
    const toggleTaskFormBtn = await base.find(fields.toggleTaskFormBtn);
    const taskTitle = await base.find(taskExpandedCard.taskTitle).getText();
    const taskDescription = await base.find(taskExpandedCard.taskDescription).getText();
    const completed = await base.find(taskExpandedCard.completedCheckbox).getAttribute('checked');
    const deadline = await base.find(taskExpandedCard.taskDeadline(1)).getText();
    toggleTaskFormBtn.click();
    toggleTaskFormBtn.click();
    return {
      taskTitle,
      taskDescription,
      deadline,
      completed,
    }
  },
  logOut: async () => {
    const logoutLink = await base.find(elements.logoutLink).click();
    return null;
  }
};

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
    await base.find(fields.saveTaskBtn).click();
    const contentHeader = await base.find(elements.taskContentHeader).getText();
    const taskTitle = await base.find(tasksContainer.createdTodoTitle).getText();
    const toggleTaskBtn = await base.find(tasksContainer.toggleTaskDisplayBtn);
    toggleTaskBtn.click();
    base.driver.sleep(1000);
    toggleTaskBtn.click();
    base.driver.sleep(1000);
    toggleTaskBtn.click();
    return {
      contentHeader,
      taskTitle,
      toggleTaskBtnText: toggleTaskBtn.getText(),
    }
  },
  taskContentCard: async () => {
    const toggleTaskFormBtn = await base.find(fields.toggleTaskFormBtn);
    const taskTitle = await base.find(taskExpandedCard.taskTitle).getText();
    const taskDescription = await base.find(taskExpandedCard.taskDescription).getText();
    const completedCheckBox = await base.find(taskExpandedCard.completedCheckbox);
    toggleTaskFormBtn.click();
    base.driver.sleep(3000);
    toggleTaskFormBtn.click();
    return {
      taskTitle,
      taskDescription,
    }
  },
  logOut: async () => {
    const logoutLink = await base.find(elements.logoutLink).click();
    return null;
  }
};

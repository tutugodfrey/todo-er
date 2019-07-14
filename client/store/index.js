import UserStore from './userStore';
import TodoStore from './todoStore';

class RootStore {
  constructor() {
    this.userStore = new UserStore(this)
    this.todoStore = new TodoStore(this);
  }
}

const rootStore = new RootStore();

export default rootStore;

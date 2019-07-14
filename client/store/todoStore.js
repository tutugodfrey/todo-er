import { observable, action, computed } from 'mobx';

class TodoStore {
  @observable todos = [];

  constructor(rootStore) {
    this.rootStore = rootStore
  }

  @action setTodo = todos => {
    return this.todos = todos;
  };

  @action addTodo = todo => {
    return this.todos.push(todo);
  };

  @action updateTodo = updatedTodo => {
    this.todos.filter((todo, index )=> {
      if (todo.id === updatedTodo.id) {
        return this.todos[index] = updatedTodo;
      }
    });
  };

  @computed get getTodos() {
    return this.todos.map(todo => {
      const keys = Object.keys();
      return keys.map(key => ({
        [key]: todo[key]
      }));
    });
  };
}

export default TodoStore;

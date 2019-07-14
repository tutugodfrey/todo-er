import { observable, action, computed } from 'mobx';

class UserStore {
  @observable user = {};

  constructor(rootStore) {
    this.rootStore = rootStore
  }

  @action setUser = user => {
    this.user = user
  };

  @computed get getUser()  {
    const newUser = {};
    Object.keys(this.user || {}).map(key => {
      newUser[key] = this.user[key]
    });
    return newUser
  }
}

export default UserStore;

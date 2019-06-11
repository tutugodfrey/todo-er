import  { decorate, observable, action } from 'mobx';
// import { observer } from 'mobx-react';

class Store {
  @observable user = {};
  @observable todos = [];

  addUser = (user) => {
    this.user = user;
  }
}

const store = new Store();
export default store;
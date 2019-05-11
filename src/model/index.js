import DataModela from 'data-modela';

const users = new DataModela('users', ['name', 'username', 'email', 'password'], ['username']);
const todos = new DataModela('todos', ['title', 'description', 'userId'], ['title']);

export {
  users,
  todos,
};

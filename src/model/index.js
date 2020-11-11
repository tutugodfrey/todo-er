import DataModela from 'data-modela';
// import { connect } from 'data-modela'; // will uncomment when data-modela is update with connect function
import dotenv from 'dotenv-safe';
dotenv.config()
const users = new DataModela('users', ['name', 'username', 'email', 'password'], ['username']);
const todos = new DataModela('todos', ['title', 'description', 'userId'], ['title']);

if (parseInt(process.env.USE_DB)) {
  const { DATABASE_URL } = process.env;
  const connection = connect(DATABASE_URL, [ users, todos ]);
}

export {
  users,
  todos,
};

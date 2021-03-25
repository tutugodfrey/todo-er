import DataModela from 'data-modela';
import { connect } from 'data-modela'; // will uncomment when data-modela is update with connect function
import dotenv from 'dotenv-safe';
dotenv.config()
const users = new DataModela('users', {
  id: {},
  name: {
    required: true,
    dataType: 'varchar',
    charLength: 100,
  },
  username: {
    required: true,
    dataType: 'varchar',
    charLength: 100,
    unique: true,
  },
  email: {
    required: true,
    dataType: 'varchar',
    charLength: 100,
  },
  imgUrl: {
    dataType: 'varchar',
    charLength: 700,
  },
  isAdmin: {
    dataType: 'boolean',
    defaultValue: false,
  },
  password: {
    required: true,
    dataType: 'varchar',
    charLength: 100,
  },
  createdAt: {
    dataType: 'timestamp',
    required: true,
  },
  updatedAt: {
    dataType: 'timestamp',
    required: true,
  },
});

const todos = new DataModela('todos', {
  id: {},
  title: {
    dateType: 'varchar',
    required: true,
    unique: true,
  },
  description: {
    dateType: 'varchar',
    required: true,

  },
  userId: {
    dataType: 'number',
    required: true,
  },
  deadline: {
    dataType: 'timestamp',
  },
  completed: {
    dataType: 'boolean',
  },
  links: {
    dataType: 'array',
    arrayOfType: 'varchar',
    charLength: 700,
  },
  createdAt: {
    dateType: 'timestamp',
    required: true,

  },
  updatedAt: {
    dateType: 'timestamp',
    required: true,
  },
});
const dbEnvMap = {
  prod: 'DATABASE_URL',
  dev: 'DEV_DATABASE_URL',
  test: 'TEST_DATABASE_URL'
}

let { NODE_ENV } = process.env;
NODE_ENV = NODE_ENV || 'prod';

if (parseInt(process.env.USE_DB)) {
  const DATABASE_URL = process.env[dbEnvMap[NODE_ENV]]
  const connection = connect(DATABASE_URL, [ users, todos ]);
}

export {
  users,
  todos,
};

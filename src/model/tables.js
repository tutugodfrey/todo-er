import { connect } from 'data-modela'; // will uncomment when data-modela is updated with connect function
import dotenv from 'dotenv-safe';
dotenv.config();

function createTable(db_client) {
  const users = `
    CREATE TABLE IF NOT EXISTS users (
    id serial NOT NULL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    email VARCHAR(30) UNIQUE NOT NULL,
    username VARCHAR(30) UNIQUE NOT NULL,
    password VARCHAR(700) NOT NULL,
    "imgUrl" VARCHAR(70),
    "isAdmin" BOOLEAN,
    "createdAt" date NOT NULL,
    "updatedAt" date NOT NULL
    );
  `;

  const todos = `
    CREATE TABLE IF NOT EXISTS todos (
    id serial NOT NULL PRIMARY KEY,
    title VARCHAR(70) NOT NULL UNIQUE,
    description VARCHAR(700),
    "userId" INT NOT NULL,
    deadline timestamptz,
    links VARCHAR(700) [],
    completed BOOLEAN NOT NULL,
    "createdAt" date NOT NULL,
    "updatedAt" date NOT NULL
    );
  `;
  db_client.query(users)
      .then(resp => {
        console.log('USERS TABLE CREATED!')
      })
      .catch(err => console.log(err));
  
  db_client.query(todos)
      .then(resp => {
        console.log('TODOS TABLE CREATED!')
      })
  return;
}

const { DATABASE_URL } = process.env;
const db_client = connect(DATABASE_URL);
createTable(db_client);


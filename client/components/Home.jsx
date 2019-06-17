import React from 'react';
import { Link } from 'react-router-dom';
import UserContext from './userContext';

const Home = () => {
  return (
    <UserContext.Consumer>
      {createdUser => {
        return (
          <div>
          <div>
            <h1>Don't leave any task uncompleted!</h1>
            <div><strong id="story">Start using Todo-er</strong></div>
            <div><Link to='/signup'>Sign Up</Link></div>
            <div><Link to="/login">login here!</Link></div>
          </div>
        </div>
        )
      }}
    </UserContext.Consumer>
  )
}

export default Home;

import React from 'react';
import { Link } from 'react-router-dom';

const Home = () => {
  return (
    <div>
      <div>
        <h3>Don't leave any task uncompleted!</h3>
        <div><strong>Start using Todo-er</strong></div>
        <div><Link to='/signup'>Signup</Link></div>
        <div><Link to="/login">login here!</Link></div>
      </div>
    </div>
  )
}

export default Home;

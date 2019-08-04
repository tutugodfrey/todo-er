import React from 'react'
import { Link } from 'react-router-dom';

const Navigation = () => {
  return (
    <div id="nav-bar">
      <div id="profile">
        <Link to='./profile'>Profile</Link>
      </div>
    </div>
  );
}

export default Navigation;
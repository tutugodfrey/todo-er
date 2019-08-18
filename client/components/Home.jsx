import React from 'react';
import Navigation from './Navigation';
import LoginInline from './LoginInline';

const Home = () => {
  return (
    <div id="landing">
        <Navigation />
        <div id="showcase">
          <div>
          <div id="app-description">
            <h1>Don't leave any task uncompleted!</h1>
            <p id="story">Task marker let you keep track of your goals for the day</p>
          </div>
          <LoginInline />
        </div>
      </div>
    </div>
  );
}

export default Home;

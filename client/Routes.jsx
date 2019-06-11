import React from 'react';
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Home from './Home.jsx';
import Signup from './components/Signup.jsx';

const Routes = (props) => {
  return (
    <div>
      <BrowserRouter>
        <Switch>
          <Route path="/" exact component={Home} />
          <Route path="/signup" exact component={Signup} />
        </Switch>
      </BrowserRouter>
    </div>
  )
}

export default Routes;

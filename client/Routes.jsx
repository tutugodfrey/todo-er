import React from 'react';
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Home from './Home.jsx';

const Routes = () => {
  return (
    <div>
      <BrowserRouter>
        <Switch>
          <Route path="/" exact component={Home} />
        </Switch>
      </BrowserRouter>
    </div>
  )
}

export default Routes;

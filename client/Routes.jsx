import React from 'react';
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Home from './components/Home.jsx';
import Signup from './components/Signup.jsx';
import Dashboard from './components/Dashboard.jsx'

import { ROUTES } from './constants'

const Routes = (props) => {
  return (
    <div>
      <BrowserRouter>
        <Switch>
          <Route path={ROUTES.BASE} exact component={Home} />
          <Route path={ROUTES.SIGN_UP} exact component={Signup} />
          <Route path={ROUTES.DASHBOARD} exact component={Dashboard} />
        </Switch>
      </BrowserRouter>
    </div>
  )
}

export default Routes;

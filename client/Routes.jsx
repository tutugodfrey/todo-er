import React from 'react';
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Home from './components/Home.jsx';
import Signup from './components/Signup.jsx';
import Signin from './components/Signin.jsx';
import Dashboard from './components/Dashboard.jsx';
import Profile from './components/Profile.jsx';

import { ROUTES } from './constants'

const Routes = (props) => {
  return (
    <div>
      <BrowserRouter>
        <Switch>
          <Route path={ROUTES.BASE} exact component={Home} />
          <Route path={ROUTES.SIGN_UP} exact component={Signup} />
          <Route path={ROUTES.SIGN_UP} exact component={Signup} />
          <Route path={ROUTES.SIGN_IN} exact component={Signin} />
          <Route path={ROUTES.DASHBOARD} exact component={Dashboard} />
          <Route path={ROUTES.PROFILE} exact component={Profile} />
        </Switch>
      </BrowserRouter>
    </div>
  )
}

export default Routes;

import React from 'react';
import { Redirect } from 'react-router-dom';
import request from './request';
import { ROUTES } from '../constants'

function closeConsole (event) {
  this.setState({
    consoleMessage: '',
  })
}

const logout = (event) => {
  // localStorage.clear();
  // event.preventDefault()
  console.log('what sup')
  return <Redirect to="/signin" />

}

export {
  request,
  closeConsole,
  logout,
}

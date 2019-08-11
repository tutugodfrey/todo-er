import request from './request';

function closeConsole (event) {
  this.setState({
    consoleMessage: '',
  })
}

export {
  request,
  closeConsole,
}

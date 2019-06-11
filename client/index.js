import React from 'react';
import ReactDOM from 'react-dom';
import Routes from './Routes.jsx';
import { Provider } from 'mobx-react';
import store from './store.js'

const App = (props) => {
  return (
    <div>
      <Routes>
        <p>Welcome to your todo app</p>
      </Routes>
    </div>
  )
}

ReactDOM.render(
<Provider store={store}>
<App store={store} />
</Provider>,
document.getElementById('app'));

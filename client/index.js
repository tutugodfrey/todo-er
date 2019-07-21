import React from 'react';
import ReactDOM from 'react-dom';
import Routes from './Routes.jsx';
import { Provider } from 'mobx-react';
import store from './store'
import './styles/index.scss'
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
<Provider {...store}>
  <App />
</Provider>,
document.getElementById('app'));

export default App;
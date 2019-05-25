import React from 'react';
import ReactDOM from 'react-dom';
import Routes from './Routes.jsx';

const App = () => {
  return (
    <div>
      <Routes>
        <p>Welcome to your todo app</p>
      </Routes>
    </div>
  )
}

ReactDOM.render(<App />, document.getElementById('app'));

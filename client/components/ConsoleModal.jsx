import React from 'react';

const ConsoleModal = ({ message, closeConsole }) => {
  return (
    <div id="console-modal">
      <button onClick={closeConsole}>x</button>
      <p>{message}</p>
    </div>
  );
};

export default ConsoleModal;

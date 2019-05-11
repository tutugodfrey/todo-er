import { users, todos } from '../model';

class TodoController {
  static createTodo(req, res) {
    const todo = req.body;
    todo.complete = false;
    // check that the user with userId exist
    return users
      .findById(req.body.userId)
      .then(user => {
        // create the todo item
        return todos
        .create(todo)
        .then(todo => {
          return res.status(201).json(todo);
        })
      })
      .catch(err => res.status(500).json(err))
  }
}

export default TodoController;

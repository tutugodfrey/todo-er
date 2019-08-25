export default {
  createTodo: (req, res, next) => {
    const fields = ['title', 'description'];
    let count = 0
    fields.forEach(field => {
      if (!req.body[field]) 
      return res.status(400).json({
        message:  `${field} is required to create todo`, 
      });
      count++
    });

    // check that all fields are validated 
    if (fields.length === count) {
      return next();
    }
  }
}
export default {
  signup: (req, res, next) => {
    let count = 0
    const fields = ['password', 'confirmPassword', 'name', 'email', 'username'];
    fields.forEach(field => {
      if (!req.body[field]) 
      return res.status(400).json({
        message:  `${field} is required to sign up`, 
      });
      count++
    });

    // check that all fields are validated 
    if (fields.length === count) {
      if (req.body['password'] !== req.body['confirmPassword'])
        return res.status(401).json({ message: 'Passwords does not match' })
      return next();
    }
  },
  signin: (req, res, next) => {
    let count = 0
    const fields = ['password', 'username'];
    fields.forEach(field => {
      if (!req.body[field]) 
      return res.status(400).json({
        message:  `${field} is required to sign in`, 
      });
      count++
    });

    // check that all fields are validated 
    if (fields.length === count) {
      return next();
    }
  },
};

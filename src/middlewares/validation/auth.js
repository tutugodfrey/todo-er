export default {
  signup: (req, res, next) => {
    const {
      password,
      name,
    } = req.body;
    let count = 0
    const fields = ['password', 'name', 'email', 'username'];
    fields.forEach(field => {
      if (!req.body[field]) 
      return res.status(400).json({
        message:  `${field} is required to sign up`, 
      });
      count++
    });

    // check that all fields are validated 
    if (fields.length === count) {
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

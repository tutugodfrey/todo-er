import jwt from 'jsonwebtoken';
import dotenv from 'dotenv-safe';

dotenv.config()
const { JWT_SECRET } = process.env;

const genToken = async (user) =>  {
  const token = await jwt.sign({
    user
  }, JWT_SECRET, { expiresIn: 60 * 60 });
  return token;
}

const authUser = async (req, res, next) => {
  const token = req.headers.token;
  if (!token) return res.status(401).json({ message: 'Please provide a token' });
  try {

    const decoded = jwt.verify(token, JWT_SECRET);
    req.body.userId = decoded.user.id;

    // temp hold user obj when unloading files
    req.userObj = {
      userId: decoded.user.id,
    }
    return next()
  } catch(err) {
    // err
    return res.status(401).json({ message: 'invalid token'})
  }
}

export {
  genToken,
  authUser,
}

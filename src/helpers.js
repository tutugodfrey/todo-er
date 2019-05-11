import jwt from 'jsonwebtoken';
import dotenv from 'dotenv-safe';

dotenv.config()

const genToken = async (userObj) =>  {
  const { JWT_SECRET } = process.env;
  const token = await jwt.sign({
    userObj
  }, JWT_SECRET, { expiresIn: 60 * 60 });
  return token;
}

export {
  genToken,
}

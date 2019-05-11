
import express from 'express';
import bodyParser from 'body-parser';
import router from './routes/index'

const port = process.env.PORT || 3001;
const app = express();
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(router)
app.listen(port, () => {
  console.log(`Todo-er start on port ${port}`)
});

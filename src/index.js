
import express from 'express';
import bodyParser from 'body-parser';
import router from './routes/index'
import cors from 'cors';

const port = process.env.PORT || 3005;
const app = express();
app.use(cors());
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));
app.use('/api', router)

// important to keep catch-all route last
app.get('/*', (re, res, next) => {
  res.status(200).sendFile('index.html', { root: './public' });
});
app.listen(port, () => {
  console.log(`Todo-er start on port ${port}`)
});


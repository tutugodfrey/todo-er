
import express from 'express';
import bodyParser from 'body-parser';
import router from './routes/index'

const port = process.env.PORT || 3005;
const app = express();
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));

app.get('*', (req, res) => {
  res.status(200).sendFile(__dirname + '/public/index.html');
});

app.use('/api', router)
app.listen(port, () => {
  console.log(`Todo-er start on port ${port}`)
});

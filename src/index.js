
import express from 'express';
import bodyParser from 'body-parser';
import router from './routes/index';
import promClient from 'prom-client';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));
app.use('/api', router)

const collectDefaultMetrics = promClient.collectDefaultMetrics;
app.get('/metrics', (req, res) => {
  const Registry = promClient.Registry;
  const registry = new Registry();
  const metrics = collectDefaultMetrics({ registry })
  res.json({ message: metrics })
});

// important to keep catch-all route last
app.get('/*', (req, res) => {
  res.status(200).sendFile('index.html', { root: './public' });
});

export default app;

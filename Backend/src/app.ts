import express from 'express';
import cors from 'cors';
import type { Application} from 'express';

const app: Application = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (_req, res) => {
    res.json(({ status: 'ok' }));
})

export default app;
import app from './app.ts';
import { config } from 'dotenv';

config();

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
// ESM version
import { start } from 'unleash-server';

const options = {
  authentication: { type: 'none' }
};

await start(options);

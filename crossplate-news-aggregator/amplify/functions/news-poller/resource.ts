import { defineFunction, secret } from '@aws-amplify/backend';

export const newsPoller = defineFunction({
  name: 'news-poller',
  entry: './handler.ts',
  schedule: 'every 15m',
  timeoutSeconds: 60,
  environment: {
    NEWS_API_KEY: secret('NEWS_API_KEY'),
  },
});

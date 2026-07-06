import { generateClient } from 'aws-amplify/data';
import type { Schema } from '../../amplify/data/resource';

export const client = generateClient<Schema>();
export const TOPIC_LIST = [
  'technology',
  'business',
  'sports',
  'entertainment',
  'health',
  'science',
  'general',
] as const;

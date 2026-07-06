import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import { newsPoller } from '../functions/news-poller/resource';
import { registerDeviceTokenFn } from '../functions/register-device-token/resource';

export const TOPICS = [
  'technology',
  'business',
  'sports',
  'entertainment',
  'health',
  'science',
  'general',
] as const;

const schema = a
  .schema({
    Article: a
      .model({
        title: a.string().required(),
        description: a.string(),
        url: a.string().required(),
        imageUrl: a.string(),
        source: a.string(),
        topic: a.string().required(),
        publishedAt: a.datetime(),
      })
      .authorization((allow) => [allow.authenticated().to(['read'])]),

    TopicSubscription: a
      .model({
        topic: a.string().required(),
      })
      .authorization((allow) => [allow.owner()]),

    SavedArticle: a
      .model({
        articleId: a.string().required(),
        title: a.string().required(),
        url: a.string().required(),
        imageUrl: a.string(),
        savedAt: a.datetime(),
      })
      .authorization((allow) => [allow.owner()]),

    DeviceToken: a
      .model({
        owner: a.string().required(),
        token: a.string().required(),
        platform: a.string().required(),
        endpointArn: a.string(),
      })
      .authorization((allow) => [allow.ownerDefinedIn('owner').to(['read', 'delete'])]),

    registerDeviceToken: a
      .mutation()
      .arguments({
        token: a.string().required(),
        platform: a.string().required(),
      })
      .returns(a.ref('DeviceToken'))
      .authorization((allow) => [allow.authenticated()])
      .handler(a.handler.function(registerDeviceTokenFn)),
  })
  .authorization((allow) => [
    allow.resource(newsPoller).to(['query', 'mutate']),
    allow.resource(registerDeviceTokenFn).to(['query', 'mutate']),
  ]);

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
  },
});

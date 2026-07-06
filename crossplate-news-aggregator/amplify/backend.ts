import { defineBackend } from '@aws-amplify/backend';
import * as iam from 'aws-cdk-lib/aws-iam';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { newsPoller } from './functions/news-poller/resource';
import { registerDeviceTokenFn } from './functions/register-device-token/resource';

const backend = defineBackend({
  auth,
  data,
  newsPoller,
  registerDeviceTokenFn,
});

const newsPollerStack = backend.newsPoller.stack;
const registerDeviceTokenStack = backend.registerDeviceTokenFn.stack;

backend.newsPoller.resources.lambda.addToRolePolicy(
  new iam.PolicyStatement({
    sid: 'AllowPublishToPlatformEndpoints',
    actions: ['sns:Publish'],
    resources: [
      `arn:aws:sns:${newsPollerStack.region}:${newsPollerStack.account}:endpoint/*`,
    ],
  })
);

backend.registerDeviceTokenFn.resources.lambda.addToRolePolicy(
  new iam.PolicyStatement({
    sid: 'AllowManagePlatformEndpoints',
    actions: [
      'sns:CreatePlatformEndpoint',
      'sns:GetEndpointAttributes',
      'sns:SetEndpointAttributes',
    ],
    resources: [
      `arn:aws:sns:${registerDeviceTokenStack.region}:${registerDeviceTokenStack.account}:endpoint/*`,
      `arn:aws:sns:${registerDeviceTokenStack.region}:${registerDeviceTokenStack.account}:app/*`,
    ],
  })
);

import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { SNSClient, CreatePlatformEndpointCommand } from '@aws-sdk/client-sns';
import { env } from '$amplify/env/register-device-token';
import type { Schema } from '../../data/resource';

const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();
const sns = new SNSClient({});

function platformApplicationArnFor(platform: string): string {
  if (platform === 'ios') return env.PLATFORM_APPLICATION_ARN_IOS;
  if (platform === 'android') return env.PLATFORM_APPLICATION_ARN_ANDROID;
  throw new Error(`Unsupported platform: ${platform}`);
}

export const handler: Schema['registerDeviceToken']['functionHandler'] = async (event) => {
  const owner = event.identity && 'sub' in event.identity ? event.identity.sub : undefined;
  if (!owner) throw new Error('registerDeviceToken requires an authenticated caller');

  const { token, platform } = event.arguments;
  const platformApplicationArn = platformApplicationArnFor(platform);

  const { EndpointArn } = await sns.send(
    new CreatePlatformEndpointCommand({
      PlatformApplicationArn: platformApplicationArn,
      Token: token,
    })
  );

  const { data: existing } = await client.models.DeviceToken.list({
    filter: { owner: { eq: owner } },
  });

  if (existing.length > 0) {
    const { data: updated } = await client.models.DeviceToken.update({
      id: existing[0].id,
      token,
      platform,
      endpointArn: EndpointArn,
    });
    return updated!;
  }

  const { data: created } = await client.models.DeviceToken.create({
    owner,
    token,
    platform,
    endpointArn: EndpointArn,
  });
  return created!;
};

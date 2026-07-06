import { defineFunction, secret } from '@aws-amplify/backend';

export const registerDeviceTokenFn = defineFunction({
  name: 'register-device-token',
  entry: './handler.ts',
  environment: {
    PLATFORM_APPLICATION_ARN_IOS: secret('PLATFORM_APPLICATION_ARN_IOS'),
    PLATFORM_APPLICATION_ARN_ANDROID: secret('PLATFORM_APPLICATION_ARN_ANDROID'),
  },
});

import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';
import { client } from './amplifyClient';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

export async function registerForPushNotifications(): Promise<void> {
  if (!Device.isDevice) {
    console.log('Push notifications require a physical device.');
    return;
  }

  const { status: existingStatus } = await Notifications.getPermissionsAsync();
  let finalStatus = existingStatus;
  if (existingStatus !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }
  if (finalStatus !== 'granted') {
    console.log('Push notification permission denied.');
    return;
  }

  const { data: token, type } = await Notifications.getDevicePushTokenAsync();
  const platform = type === 'ios' ? 'ios' : 'android';

  await client.mutations.registerDeviceToken({ token, platform });

  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('default', {
      name: 'default',
      importance: Notifications.AndroidImportance.DEFAULT,
    });
  }
}

export function addNotificationResponseListener(
  onTopicTapped: (topic: string) => void
) {
  return Notifications.addNotificationResponseReceivedListener((response) => {
    const topic = response.notification.request.content.data?.topic as string | undefined;
    if (topic) onTopicTapped(topic);
  });
}

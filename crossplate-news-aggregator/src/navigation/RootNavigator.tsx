import { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { ActivityIndicator, View } from 'react-native';
import { client } from '../lib/amplifyClient';
import { addNotificationResponseListener } from '../lib/pushNotifications';
import OnboardingTopicsScreen from '../screens/OnboardingTopicsScreen';
import FeedScreen from '../screens/FeedScreen';
import SavedScreen from '../screens/SavedScreen';
import SettingsScreen from '../screens/SettingsScreen';
import ArticleDetailScreen from '../screens/ArticleDetailScreen';
import type { Schema } from '../../amplify/data/resource';

type Article = Schema['Article']['type'];

export type ArticleDetailParams = {
  id: string;
  title: string;
  url: string;
  imageUrl?: string | null;
  description?: string | null;
  source?: string | null;
  topic?: string | null;
};

export type MainTabParamList = {
  Feed: undefined;
  Saved: undefined;
  Settings: undefined;
};

export type RootStackParamList = {
  Onboarding: undefined;
  MainTabs: undefined;
  ArticleDetail: { article: Article | ArticleDetailParams };
};

const Tab = createBottomTabNavigator<MainTabParamList>();
const Stack = createNativeStackNavigator<RootStackParamList>();

function MainTabs() {
  return (
    <Tab.Navigator screenOptions={{ headerShown: false }}>
      <Tab.Screen name="Feed" component={FeedScreen} />
      <Tab.Screen name="Saved" component={SavedScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

export default function RootNavigator() {
  const [loading, setLoading] = useState(true);
  const [hasTopics, setHasTopics] = useState(false);

  useEffect(() => {
    client.models.TopicSubscription.list().then(({ data }) => {
      setHasTopics(data.length > 0);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    const sub = addNotificationResponseListener(() => {
      // Deep link target is the Feed tab; topic filtering already applies there.
    });
    return () => sub.remove();
  }, []);

  if (loading) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <ActivityIndicator />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {!hasTopics && (
          <Stack.Screen name="Onboarding">
            {() => <OnboardingTopicsScreen onDone={() => setHasTopics(true)} />}
          </Stack.Screen>
        )}
        {hasTopics && (
          <>
            <Stack.Screen name="MainTabs" component={MainTabs} />
            <Stack.Screen
              name="ArticleDetail"
              component={ArticleDetailScreen}
              options={{ headerShown: true, title: '' }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

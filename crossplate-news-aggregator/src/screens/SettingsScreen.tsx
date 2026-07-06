import { useEffect, useState } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuthenticator } from '@aws-amplify/ui-react-native';
import { client, TOPIC_LIST } from '../lib/amplifyClient';
import { registerForPushNotifications } from '../lib/pushNotifications';
import type { Schema } from '../../amplify/data/resource';

type TopicSubscription = Schema['TopicSubscription']['type'];

export default function SettingsScreen() {
  const { signOut } = useAuthenticator();
  const [subscriptions, setSubscriptions] = useState<TopicSubscription[]>([]);

  useEffect(() => {
    const sub = client.models.TopicSubscription.observeQuery().subscribe({
      next: ({ items }) => setSubscriptions(items),
    });
    return () => sub.unsubscribe();
  }, []);

  async function toggle(topic: string) {
    const existing = subscriptions.find((s) => s.topic === topic);
    if (existing) {
      await client.models.TopicSubscription.delete({ id: existing.id });
    } else {
      await client.models.TopicSubscription.create({ topic });
    }
  }

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <ScrollView contentContainerStyle={{ padding: 16 }}>
        <Text style={styles.header}>Settings</Text>

        <Text style={styles.sectionLabel}>Your topics</Text>
        <View style={styles.topicGrid}>
          {TOPIC_LIST.map((topic) => {
            const isSelected = subscriptions.some((s) => s.topic === topic);
            return (
              <Pressable
                key={topic}
                onPress={() => toggle(topic)}
                style={[styles.chip, isSelected && styles.chipSelected]}
              >
                <Text style={[styles.chipText, isSelected && styles.chipTextSelected]}>
                  {topic}
                </Text>
              </Pressable>
            );
          })}
        </View>

        <Pressable style={styles.rowButton} onPress={() => registerForPushNotifications()}>
          <Text style={styles.rowButtonText}>Re-enable push notifications</Text>
        </Pressable>

        <Pressable style={[styles.rowButton, styles.signOutButton]} onPress={signOut}>
          <Text style={[styles.rowButtonText, styles.signOutText]}>Sign out</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { fontSize: 28, fontWeight: '800', marginBottom: 20 },
  sectionLabel: { fontSize: 13, fontWeight: '700', color: '#888', marginBottom: 10 },
  topicGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginBottom: 24 },
  chip: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  chipSelected: { backgroundColor: '#111', borderColor: '#111' },
  chipText: { fontSize: 14, color: '#111', textTransform: 'capitalize' },
  chipTextSelected: { color: '#fff' },
  rowButton: {
    backgroundColor: '#f0f0f0',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
    marginBottom: 12,
  },
  rowButtonText: { fontWeight: '600', color: '#111' },
  signOutButton: { backgroundColor: '#fdeaea' },
  signOutText: { color: '#c0392b' },
});

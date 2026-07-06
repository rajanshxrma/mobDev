import { useState } from 'react';
import { View, Text, Pressable, StyleSheet, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { client, TOPIC_LIST } from '../lib/amplifyClient';
import { registerForPushNotifications } from '../lib/pushNotifications';

export default function OnboardingTopicsScreen({ onDone }: { onDone: () => void }) {
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [saving, setSaving] = useState(false);

  function toggle(topic: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(topic) ? next.delete(topic) : next.add(topic);
      return next;
    });
  }

  async function handleContinue() {
    setSaving(true);
    try {
      await Promise.all(
        [...selected].map((topic) => client.models.TopicSubscription.create({ topic }))
      );
      await registerForPushNotifications();
    } finally {
      setSaving(false);
      onDone();
    }
  }

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>What do you want to follow?</Text>
      <Text style={styles.subtitle}>
        Pick a few topics. You'll get a push notification when fresh news lands.
      </Text>
      <View style={styles.topicGrid}>
        {TOPIC_LIST.map((topic) => {
          const isSelected = selected.has(topic);
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
      <Pressable
        style={[styles.continueButton, selected.size === 0 && styles.continueButtonDisabled]}
        disabled={selected.size === 0 || saving}
        onPress={handleContinue}
      >
        {saving ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.continueText}>Continue</Text>
        )}
      </Pressable>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', padding: 24 },
  title: { fontSize: 26, fontWeight: '700', marginTop: 24 },
  subtitle: { fontSize: 15, color: '#666', marginTop: 8, marginBottom: 24 },
  topicGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  chip: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  chipSelected: { backgroundColor: '#111', borderColor: '#111' },
  chipText: { fontSize: 15, color: '#111', textTransform: 'capitalize' },
  chipTextSelected: { color: '#fff' },
  continueButton: {
    marginTop: 'auto',
    backgroundColor: '#111',
    borderRadius: 14,
    paddingVertical: 16,
    alignItems: 'center',
  },
  continueButtonDisabled: { opacity: 0.4 },
  continueText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});

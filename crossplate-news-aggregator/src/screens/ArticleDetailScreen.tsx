import { useEffect, useState } from 'react';
import { View, Text, Image, ScrollView, Pressable, StyleSheet, Linking } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import { client } from '../lib/amplifyClient';
import type { RootStackParamList } from '../navigation/RootNavigator';

type Props = NativeStackScreenProps<RootStackParamList, 'ArticleDetail'>;

export default function ArticleDetailScreen({ route }: Props) {
  const { article } = route.params;
  const [savedRecordId, setSavedRecordId] = useState<string | null>(null);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    client.models.SavedArticle.list({ filter: { articleId: { eq: article.id } } }).then(
      ({ data }) => {
        setSavedRecordId(data[0]?.id ?? null);
        setChecking(false);
      }
    );
  }, [article.id]);

  async function toggleSave() {
    if (savedRecordId) {
      await client.models.SavedArticle.delete({ id: savedRecordId });
      setSavedRecordId(null);
    } else {
      const { data } = await client.models.SavedArticle.create({
        articleId: article.id,
        title: article.title,
        url: article.url,
        imageUrl: article.imageUrl ?? undefined,
        savedAt: new Date().toISOString(),
      });
      setSavedRecordId(data?.id ?? null);
    }
  }

  return (
    <SafeAreaView style={styles.container} edges={['bottom']}>
      <ScrollView contentContainerStyle={{ paddingBottom: 32 }}>
        {article.imageUrl ? (
          <Image source={{ uri: article.imageUrl }} style={styles.image} />
        ) : null}
        <View style={styles.body}>
          {article.topic ? <Text style={styles.topicTag}>{article.topic}</Text> : null}
          <Text style={styles.title}>{article.title}</Text>
          {article.source ? <Text style={styles.source}>{article.source}</Text> : null}
          {article.description ? (
            <Text style={styles.description}>{article.description}</Text>
          ) : null}

          <View style={styles.actionsRow}>
            <Pressable
              style={styles.actionButton}
              onPress={() => Linking.openURL(article.url)}
            >
              <Text style={styles.actionButtonText}>Read full article</Text>
            </Pressable>
            <Pressable
              style={[styles.actionButton, styles.saveButton]}
              disabled={checking}
              onPress={toggleSave}
            >
              <Text style={[styles.actionButtonText, styles.saveButtonText]}>
                {savedRecordId ? 'Saved' : 'Save'}
              </Text>
            </Pressable>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  image: { width: '100%', height: 240 },
  body: { padding: 20, gap: 10 },
  topicTag: { fontSize: 12, fontWeight: '700', color: '#888', textTransform: 'uppercase' },
  title: { fontSize: 22, fontWeight: '700' },
  source: { fontSize: 13, color: '#999' },
  description: { fontSize: 16, color: '#333', lineHeight: 22, marginTop: 8 },
  actionsRow: { flexDirection: 'row', gap: 12, marginTop: 16 },
  actionButton: {
    flex: 1,
    backgroundColor: '#111',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  saveButton: { backgroundColor: '#f0f0f0' },
  actionButtonText: { color: '#fff', fontWeight: '600' },
  saveButtonText: { color: '#111' },
});

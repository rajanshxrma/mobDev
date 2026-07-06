import { useEffect, useMemo, useState } from 'react';
import { View, Text, Image, Pressable, FlatList, StyleSheet, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { client } from '../lib/amplifyClient';
import type { RootStackParamList } from '../navigation/RootNavigator';
import type { Schema } from '../../amplify/data/resource';

type Article = Schema['Article']['type'];

export default function FeedScreen() {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const [topics, setTopics] = useState<string[]>([]);
  const [articles, setArticles] = useState<Article[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    const sub = client.models.TopicSubscription.observeQuery().subscribe({
      next: ({ items }) => setTopics(items.map((i) => i.topic)),
    });
    return () => sub.unsubscribe();
  }, []);

  const filter = useMemo(() => {
    if (topics.length === 0) return undefined;
    return { or: topics.map((topic) => ({ topic: { eq: topic } })) };
  }, [topics]);

  useEffect(() => {
    if (!filter) return;
    const sub = client.models.Article.observeQuery({ filter }).subscribe({
      next: ({ items }) => {
        const sorted = [...items].sort(
          (a, b) => new Date(b.publishedAt ?? 0).getTime() - new Date(a.publishedAt ?? 0).getTime()
        );
        setArticles(sorted);
        setRefreshing(false);
      },
    });
    return () => sub.unsubscribe();
  }, [filter]);

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <Text style={styles.header}>CrossPlate</Text>
      <FlatList
        data={articles}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ padding: 16, gap: 12 }}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={() => setRefreshing(true)} />
        }
        ListEmptyComponent={
          <Text style={styles.empty}>
            No articles yet for your topics. New ones arrive automatically every 15 minutes.
          </Text>
        }
        renderItem={({ item }) => (
          <Pressable
            style={styles.card}
            onPress={() => navigation.navigate('ArticleDetail', { article: item })}
          >
            {item.imageUrl ? (
              <Image source={{ uri: item.imageUrl }} style={styles.thumbnail} />
            ) : null}
            <View style={styles.cardBody}>
              <Text style={styles.topicTag}>{item.topic}</Text>
              <Text style={styles.title} numberOfLines={3}>
                {item.title}
              </Text>
              <Text style={styles.source}>{item.source}</Text>
            </View>
          </Pressable>
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { fontSize: 28, fontWeight: '800', paddingHorizontal: 16, paddingTop: 8 },
  empty: { textAlign: 'center', color: '#888', marginTop: 40, paddingHorizontal: 24 },
  card: {
    flexDirection: 'row',
    borderRadius: 14,
    overflow: 'hidden',
    backgroundColor: '#f7f7f7',
  },
  thumbnail: { width: 96, height: 96 },
  cardBody: { flex: 1, padding: 12, gap: 4, justifyContent: 'center' },
  topicTag: { fontSize: 11, fontWeight: '700', color: '#888', textTransform: 'uppercase' },
  title: { fontSize: 15, fontWeight: '600' },
  source: { fontSize: 12, color: '#999' },
});

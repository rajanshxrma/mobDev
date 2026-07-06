import { useEffect, useState } from 'react';
import { View, Text, Image, Pressable, FlatList, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { client } from '../lib/amplifyClient';
import type { RootStackParamList } from '../navigation/RootNavigator';
import type { Schema } from '../../amplify/data/resource';

type SavedArticle = Schema['SavedArticle']['type'];

export default function SavedScreen() {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const [saved, setSaved] = useState<SavedArticle[]>([]);

  useEffect(() => {
    const sub = client.models.SavedArticle.observeQuery().subscribe({
      next: ({ items }) => {
        const sorted = [...items].sort(
          (a, b) => new Date(b.savedAt ?? 0).getTime() - new Date(a.savedAt ?? 0).getTime()
        );
        setSaved(sorted);
      },
    });
    return () => sub.unsubscribe();
  }, []);

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      <Text style={styles.header}>Saved</Text>
      <FlatList
        data={saved}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ padding: 16, gap: 12 }}
        ListEmptyComponent={
          <Text style={styles.empty}>Articles you save will show up here.</Text>
        }
        renderItem={({ item }) => (
          <Pressable
            style={styles.card}
            onPress={() =>
              navigation.navigate('ArticleDetail', {
                article: {
                  id: item.articleId,
                  title: item.title,
                  url: item.url,
                  imageUrl: item.imageUrl,
                },
              })
            }
          >
            {item.imageUrl ? (
              <Image source={{ uri: item.imageUrl }} style={styles.thumbnail} />
            ) : null}
            <View style={styles.cardBody}>
              <Text style={styles.title} numberOfLines={3}>
                {item.title}
              </Text>
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
  cardBody: { flex: 1, padding: 12, justifyContent: 'center' },
  title: { fontSize: 15, fontWeight: '600' },
});

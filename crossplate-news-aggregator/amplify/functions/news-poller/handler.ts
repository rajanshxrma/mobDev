import type { Handler } from 'aws-lambda';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { env } from '$amplify/env/news-poller';
import type { Schema } from '../../data/resource';
import { TOPICS } from '../../data/resource';

const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();
const sns = new SNSClient({});

type NewsApiArticle = {
  title: string;
  description: string | null;
  url: string;
  urlToImage: string | null;
  source: { name: string };
  publishedAt: string;
};

async function fetchTopHeadlines(topic: string): Promise<NewsApiArticle[]> {
  const url = new URL('https://newsapi.org/v2/top-headlines');
  url.searchParams.set('category', topic);
  url.searchParams.set('language', 'en');
  url.searchParams.set('pageSize', '10');
  url.searchParams.set('apiKey', env.NEWS_API_KEY);

  const response = await fetch(url.toString());
  if (!response.ok) {
    console.error(`NewsAPI request failed for topic "${topic}": ${response.status}`);
    return [];
  }
  const body = (await response.json()) as { articles: NewsApiArticle[] };
  return body.articles ?? [];
}

async function notifySubscribers(topic: string) {
  const { data: subscriptions } = await client.models.TopicSubscription.list({
    filter: { topic: { eq: topic } },
  });

  const owners = [...new Set(subscriptions.map((s) => s.owner).filter((o): o is string => !!o))];

  for (const owner of owners) {
    const { data: tokens } = await client.models.DeviceToken.list({
      filter: { owner: { eq: owner } },
    });

    for (const deviceToken of tokens) {
      if (!deviceToken.endpointArn) continue;
      try {
        await sns.send(
          new PublishCommand({
            TargetArn: deviceToken.endpointArn,
            MessageStructure: 'json',
            Message: JSON.stringify({
              default: `New ${topic} news`,
              APNS: JSON.stringify({
                aps: { alert: `New ${topic} news is available`, sound: 'default' },
                topic,
              }),
              GCM: JSON.stringify({
                notification: { title: 'CrossPlate News', body: `New ${topic} news is available` },
                data: { topic },
              }),
            }),
          })
        );
      } catch (err) {
        console.error(`Failed to publish to endpoint ${deviceToken.endpointArn}`, err);
      }
    }
  }
}

export const handler: Handler = async () => {
  for (const topic of TOPICS) {
    const articles = await fetchTopHeadlines(topic);
    let createdAny = false;

    for (const article of articles) {
      if (!article.url || !article.title) continue;

      const { data: existing } = await client.models.Article.list({
        filter: { url: { eq: article.url } },
      });
      if (existing.length > 0) continue;

      await client.models.Article.create({
        title: article.title,
        description: article.description ?? undefined,
        url: article.url,
        imageUrl: article.urlToImage ?? undefined,
        source: article.source?.name,
        topic,
        publishedAt: article.publishedAt,
      });
      createdAny = true;
    }

    if (createdAny) {
      await notifySubscribers(topic);
    }
  }

  return { statusCode: 200 };
};

# crossplate news aggregator

react native news app with topic subscriptions, saved articles, and custom push notifications, backed by an aws amplify gen 2 backend.

## ⚠️ todo before this is actually done

- [ ] get a real api key from [newsapi.org](https://newsapi.org) (free tier) and set it:
  ```
  npx ampx sandbox secret set NEWS_API_KEY
  ```
- [ ] set up sns platform applications for ios (apns) and android (fcm) — needs apple developer + firebase credentials
- [ ] set the real arns once you have them:
  ```
  npx ampx sandbox secret set PLATFORM_APPLICATION_ARN_IOS
  npx ampx sandbox secret set PLATFORM_APPLICATION_ARN_ANDROID
  ```
- [ ] redeploy the backend: `npx ampx sandbox --once`
- [ ] **test push notifications end-to-end on a physical device** — not expo go, needs a custom dev build since remote push requires native fcm/apns tokens (expo go dropped remote push support in sdk 53+)

everything else (sign up/in, feed, saved articles, topic settings) already works and is testable today via expo go.

## how it works

```
news-poller (lambda, every 15m)
  → fetches newsapi.org top headlines per topic
  → dedupes + writes new Article records (appsync/dynamodb)
  → publishes push via sns to subscribers' registered device tokens

app registers device token (native fcm/apns token, not expo's push token)
  → register-device-token (lambda) creates an sns platform endpoint
  → stored on the user's DeviceToken record
```

## stack

- **app:** expo (sdk 57) + typescript, react-navigation, expo-notifications
- **backend:** aws amplify gen 2 — cognito auth, appsync/dynamodb (Article, TopicSubscription, SavedArticle, DeviceToken), two lambdas (news-poller, register-device-token), sns for push delivery

amplify gen 2 was used over gen 1 (which is in maintenance mode, eol may 2027).

## setup

```bash
npm install
npx ampx sandbox        # deploys your own backend + writes amplify_outputs.json
npx expo start
```

secrets (`NEWS_API_KEY`, `PLATFORM_APPLICATION_ARN_IOS`, `PLATFORM_APPLICATION_ARN_ANDROID`) are managed via `npx ampx sandbox secret set <NAME>`, not committed to the repo.

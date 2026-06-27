# NextTrain

AI-powered train delay estimation app for **Sri Lanka Railways**, built with Flutter, Firebase, and Google Gemini.

## Features

- Email/password authentication (sign up, sign in, password reset)
- Smart delay estimation from train, route, weather, and schedule factors
- Prediction history synced to Firestore (swipe to delete)
- Gemini AI assistant for railway Q&A
- User profile and settings (notifications, change password)

## Setup

### 1. Flutter

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get
```

### 2. Firebase

- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`
- Dart: `lib/firebase_options.dart`

In [Firebase Console](https://console.firebase.google.com/):

1. Enable **Email/Password** under Authentication → Sign-in method
2. Create a **Firestore** database
3. Deploy rules: `firebase deploy --only firestore:rules` (see `firestore.rules`)

### 3. Gemini API

Copy `.env.example` to `.env` and add your key from [Google AI Studio](https://aistudio.google.com/apikey):

```env
GEMINI_API_KEY=your_key_here
```

## Run

```bash
flutter run
```

## Test

```bash
flutter test
bash scripts/e2e_verify.sh
```

## Project structure

| Path | Purpose |
|------|---------|
| `lib/screens/` | UI screens |
| `lib/services/` | Firebase backend, Gemini, session |
| `lib/config/` | API configuration |
| `test/e2e/` | Widget and live API tests |

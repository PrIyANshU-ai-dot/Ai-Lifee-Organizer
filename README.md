# AI Life Organizer

A production-ready Flutter app using **Clean Architecture** (feature-first), **Riverpod**, **GoRouter**, and **Firebase**.

## Architecture

- **Core**: Theme, config (`EnvConfig`), services (mock AI), utils (date).
- **Features**: Each feature has `data/` (repositories, Firestore), `domain/` (entities, repository contracts), `presentation/` (screens, providers).
- **Shared**: Reusable widgets (gradient background, loading, empty state), global providers (repositories, AI service).

## Setup

1. **Flutter**: `flutter pub get`
2. **Firebase**:
   - Create a project at [Firebase Console](https://console.firebase.google.com).
   - Add Android/iOS/Web apps and download:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
   - For web, run `dart run flutterfire_cli configure` (or add Firebase config in `lib/firebase_options.dart`).
3. **Firestore**:
   - Enable Firestore and create a database.
   - Deploy indexes (optional, for composite queries):  
     `firebase deploy --only firestore:indexes`  
     (uses `firestore.indexes.json` in the project root.)
4. **Auth**: Enable Email/Password in Firebase Authentication.

## Run

```bash
flutter run
```

## MVP Features

- **Auth**: Email/password login, signup, logout; user profile in Firestore (`users`).
- **Goals**: Create goal (title + deadline); mock AI returns structured tasks (JSON); goal and tasks stored in Firestore (`goals`, `goals/{id}/tasks`).
- **Dashboard**: Today’s tasks, circular progress, mark complete; real-time Firestore.
- **Insights**: Total tasks, completed count, completion %, bar chart (fl_chart).

## Env config

See `lib/core/config/env_config.dart`. Use `--dart-define` or `String.fromEnvironment` for API URL and keys in production.

## Tech stack

- **State**: Riverpod  
- **Navigation**: GoRouter (with auth redirect)  
- **Models**: Freezed (auth, goals, tasks); plain class for AI-generated task JSON  
- **Networking**: Dio (for future AI API); mock AI in `core/services/ai_service.dart`  
- **Charts**: fl_chart  

## Project structure (lib)

```
lib/
  core/           # theme, config, services, utils
  features/
    auth/         # data, domain, presentation
    goals/
    dashboard/
    insights/
  shared/         # widgets, providers
  router/         # GoRouter config
  app_shell.dart
  main.dart
```

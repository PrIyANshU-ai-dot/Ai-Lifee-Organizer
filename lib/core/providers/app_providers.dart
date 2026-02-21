import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global app-level providers and configuration.
/// Centralized provider setup for dependency injection.

/// App-wide error handler provider (can be extended for global error handling).
final appErrorHandlerProvider = Provider<void Function(Object error, StackTrace stackTrace)>((ref) {
  return (error, stackTrace) {
    // Global error handler - can integrate with crash reporting, logging, etc.
    // Example: Firebase Crashlytics, Sentry, etc.
    if (kDebugMode) {
      debugPrint('App error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  };
});

/// App state provider (can track app lifecycle, connectivity, etc.).
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppState {
  const AppState({
    this.isInitialized = false,
    this.isOnline = true,
  });

  final bool isInitialized;
  final bool isOnline;

  AppState copyWith({
    bool? isInitialized,
    bool? isOnline,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setInitialized(bool value) {
    state = state.copyWith(isInitialized: value);
  }

  void setOnline(bool value) {
    state = state.copyWith(isOnline: value);
  }
}

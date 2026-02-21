import 'package:ai_life_organizer/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';

/// Stream of current user profile; null when signed out.
final currentUserProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

/// One-time current user (e.g. for redirect logic).
final currentUserOnceProvider = FutureProvider<UserProfile?>((ref) {
  return ref.read(authRepositoryProvider).getCurrentUser();
});

import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real-time goals for the currently signed-in user.
///
/// Design note:
/// - Uses the domain repository abstraction (`GoalsRepository`) to keep the
///   presentation layer independent of Firestore details.
/// - Reads from `users/{uid}/goals` via `GoalsRepositoryImpl.watchGoals`.
final currentUserGoalsProvider = StreamProvider.autoDispose<List<Goal>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.read(goalsRepositoryProvider).watchGoals(user.id);
});


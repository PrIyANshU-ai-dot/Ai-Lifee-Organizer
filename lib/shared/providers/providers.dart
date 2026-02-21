import 'package:ai_life_organizer/core/services/ai_service.dart';
import 'package:ai_life_organizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ai_life_organizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_life_organizer/features/dashboard/data/repositories/tasks_repository_impl.dart';
import 'package:ai_life_organizer/features/dashboard/domain/repositories/tasks_repository.dart';
import 'package:ai_life_organizer/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:ai_life_organizer/features/goals/domain/repositories/goals_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global providers for repositories and services (dependency injection).
/// Keeps presentation layer independent of concrete implementations.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepositoryImpl(aiService: MockAiService());
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return MockAiService();
});

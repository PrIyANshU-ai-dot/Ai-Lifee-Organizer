import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';

/// Repository contract for goals and AI-generated tasks (domain layer).
abstract class GoalsRepository {
  /// Create a goal, generate tasks via AI service, and store goal + tasks in Firestore.
  Future<Goal> createGoalWithTasks({
    required String userId,
    required String title,
    required DateTime deadline,
  });

  /// Stream of goals for a user.
  Stream<List<Goal>> watchGoals(String userId);
}

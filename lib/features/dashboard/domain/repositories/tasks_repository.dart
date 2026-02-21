import 'package:ai_life_organizer/features/dashboard/domain/entities/task_entity.dart';

/// Aggregate stats for insights screen.
class TasksStats {
  const TasksStats({
    required this.total,
    required this.completed,
  });
  final int total;
  final int completed;
  double get completionPercentage => total > 0 ? (completed / total) * 100 : 0.0;
}

/// Repository for tasks (dashboard: today's tasks, mark complete; insights: stats).
abstract class TasksRepository {
  /// Stream tasks due on [dateStr] (yyyy-MM-dd) for user [userId].
  Stream<List<TaskEntity>> watchTasksForDate(String userId, String dateStr);

  /// Toggle task completion.
  Future<void> setTaskCompleted(String goalId, String taskId, bool completed);

  /// Stream of aggregate task stats for user (for insights).
  Stream<TasksStats> watchTasksStats(String userId);
}

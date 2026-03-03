import 'package:ai_life_organizer/features/dashboard/domain/entities/task_entity.dart';
import 'package:ai_life_organizer/features/dashboard/domain/repositories/tasks_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

/// Firestore implementation: tasks live under users/{userId}/goals/{goalId}/tasks.
/// Real-time: combines streams from each goal's tasks subcollection.
class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _goalsCollection = 'goals';
  static const String _tasksSubcollection = 'tasks';

  @override
  Stream<List<TaskEntity>> watchTasksForDate(String userId, String dateStr) {
    // The original implementation looked at a top-level "goals" collection and
    // filtered by userId. After moving goals under users/{uid}/goals, we must
    // scope all queries to the per-user subcollection so dashboard providers
    // stay in sync.
    final goalsStream = _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .snapshots();

    return goalsStream.switchMap((goalsSnap) {
      if (goalsSnap.docs.isEmpty) {
        return Stream.value(<TaskEntity>[]);
      }
      final streams = goalsSnap.docs.map((goalDoc) {
        return goalDoc.reference
            .collection(_tasksSubcollection)
            .where('dueDate', isEqualTo: dateStr)
            .orderBy('order')
            .snapshots()
            .map((taskSnap) {
          return taskSnap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return TaskEntity.fromFirestore(data, doc.id);
          }).toList();
        });
      });
      return Rx.combineLatestList<List<TaskEntity>>(streams).map((lists) {
        final combined = <TaskEntity>[];
        for (final list in lists) {
          combined.addAll(list);
        }
        combined.sort((a, b) => a.order.compareTo(b.order));
        return combined;
      });
    });
  }

  @override
  Future<void> setTaskCompleted(
    String userId,
    String goalId,
    String taskId,
    bool completed,
  ) async {
    // After nesting goals under users/{uid}, we also need the userId here
    // so that task updates hit the correct document path.
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .doc(goalId)
        .collection(_tasksSubcollection)
        .doc(taskId)
        .update({
      'completed': completed,
      'completedAt': completed ? DateTime.now().toIso8601String() : null,
    });
  }

  @override
  Stream<TasksStats> watchTasksStats(String userId) {
    final goalsStream = _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .snapshots();

    return goalsStream.switchMap((goalsSnap) {
      if (goalsSnap.docs.isEmpty) {
        return Stream.value(const TasksStats(total: 0, completed: 0));
      }
      final streams = goalsSnap.docs.map((goalDoc) {
        return goalDoc.reference
            .collection(_tasksSubcollection)
            .snapshots()
            .map((taskSnap) {
          var completed = 0;
          for (final doc in taskSnap.docs) {
            if (doc.data()['completed'] == true) {
              completed++;
            }
          }
          return _TaskCount(total: taskSnap.docs.length, completed: completed);
        });
      });
      return Rx.combineLatestList<_TaskCount>(streams).map((counts) {
        var total = 0, completed = 0;
        for (final c in counts) {
          total += c.total;
          completed += c.completed;
        }
        return TasksStats(total: total, completed: completed);
      });
    });
  }
}

class _TaskCount {
  _TaskCount({required this.total, required this.completed});
  final int total;
  final int completed;
}

import 'package:ai_life_organizer/core/services/ai_service.dart';
import 'package:ai_life_organizer/core/utils/date_utils.dart';
import 'package:ai_life_organizer/features/dashboard/domain/entities/task_entity.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/generated_task.dart';
import 'package:ai_life_organizer/features/goals/domain/repositories/goals_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Implementation of [GoalsRepository]: AI service + Firestore.
class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({
    AiService? aiService,
    FirebaseFirestore? firestore,
  })  : _aiService = aiService ?? MockAiService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final AiService _aiService;
  final FirebaseFirestore _firestore;

  static const String _goalsCollection = 'goals';
  static const String _tasksSubcollection = 'tasks';

  @override
  Future<Goal> createGoalWithTasks({
    required String userId,
    required String title,
    required DateTime deadline,
  }) async {
    final deadlineStr = AppDateUtils.toStorageDate(deadline);

    // 1) Generate tasks from AI (mock for MVP)
    final List<GeneratedTask> generated = await _aiService.generateTasks(
      goalTitle: title,
      deadline: deadline,
    );

    // 2) Create goal document
    final goalRef = _firestore.collection(_goalsCollection).doc();
    final goal = Goal(
      id: goalRef.id,
      userId: userId,
      title: title,
      deadlineDate: deadlineStr,
      createdAt: DateTime.now(),
    );
    await goalRef.set(goal.toFirestore());

    // 3) Distribute tasks across deadline (simple: spread by order, due date = deadline for MVP)
    final tasksRef = goalRef.collection(_tasksSubcollection);
    for (var i = 0; i < generated.length; i++) {
      final t = generated[i];
      final task = TaskEntity(
        id: '',
        goalId: goal.id,
        title: t.title,
        dueDate: deadlineStr,
        completed: false,
        order: t.order,
      );
      final docRef = tasksRef.doc();
      await docRef.set(task.toFirestore());
    }

    return goal;
  }

  @override
  Stream<List<Goal>> watchGoals(String userId) {
    return _firestore
        .collection(_goalsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Goal.fromFirestore(d.data(), d.id))
            .toList());
  }
}

import 'dart:developer' as dev;

import 'package:ai_life_organizer/core/services/ai_service.dart';
import 'package:ai_life_organizer/core/utils/date_utils.dart';
import 'package:ai_life_organizer/features/dashboard/domain/entities/task_entity.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/generated_task.dart';
import 'package:ai_life_organizer/features/goals/domain/repositories/goals_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Implementation of [GoalsRepository]: AI service + Firestore.
class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({
    AiService? aiService,
    FirebaseFirestore? firestore,
  })  : _aiService = aiService ?? MockAiService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final AiService _aiService;
  final FirebaseFirestore _firestore;

  static const String _usersCollection = 'users';
  static const String _goalsCollection = 'goals';
  static const String _tasksSubcollection = 'tasks';

  @override
  Future<Goal> createGoalWithTasks({
    required String userId,
    required String title,
    required DateTime deadline,
  }) async {
    // The original implementation wrote goals to a top-level "goals"
    // collection, which does not match the Firestore rules that expect
    // data under "users/{uid}/goals". This caused goal creation to fail
    // silently and the UI to stay on the create screen.
    if (userId.isEmpty) {
      // Fail fast with a clear error instead of silently proceeding.
      throw Exception('Cannot create goal without a user id.');
    }

    final deadlineStr = AppDateUtils.toStorageDate(deadline);

    // Double-check that FirebaseAuth has a current user and that it matches
    // the userId passed from the presentation layer. If this is not true,
    // Firestore writes are likely to be rejected by security rules.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      dev.log(
        'FirebaseAuth currentUser mismatch. currentUser=${currentUser?.uid}, requestedUserId=$userId',
        name: 'GoalsRepositoryImpl',
      );
      throw Exception('You must be signed in to create a goal.');
    }

    try {
      // 1) Generate tasks from AI (mock for MVP)
      final List<GeneratedTask> generated = await _aiService.generateTasks(
        goalTitle: title,
        deadline: deadline,
      );

      // 2) Create goal document under users/{uid}/goals with the expected schema.
      final userGoalsRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_goalsCollection);
      final goalRef = userGoalsRef.doc();

      final goal = Goal(
        id: goalRef.id,
        userId: userId,
        title: title,
        deadlineDate: deadlineStr,
        createdAt: DateTime.now(),
      );

      final goalData = goal.toFirestore()
        // Align Firestore schema with requirements:
        // { title, deadline: DateTime?, createdAt: serverTimestamp, isCompleted: false }.
        ..['deadline'] = deadline
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['isCompleted'] = false;

      // Add explicit logging to help debug Firestore failures in the field.
      dev.log(
        'Creating goal for userId=$userId at ${goalRef.path} with title="$title" and deadline=$deadline',
        name: 'GoalsRepositoryImpl',
      );

      await goalRef.set(goalData);

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

      dev.log(
        'Successfully created goal ${goal.id} with ${generated.length} tasks for userId=$userId',
        name: 'GoalsRepositoryImpl',
      );

      return goal;
    } on FirebaseException catch (e, st) {
      // Surface a clear error up to the UI instead of letting a low-level
      // FirebaseException bubble up unmodified.
      dev.log(
        'FirebaseException when creating goal for userId=$userId: ${e.code} ${e.message}',
        name: 'GoalsRepositoryImpl',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to create goal: ${e.message ?? e.code}');
    } catch (e, st) {
      dev.log(
        'Unexpected error when creating goal for userId=$userId',
        name: 'GoalsRepositoryImpl',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to create goal. Please try again.');
    }
  }

  @override
  Stream<List<Goal>> watchGoals(String userId) {
    // Watch goals scoped under the current user document so that Riverpod
    // providers stay in sync with the per-user data hierarchy.
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Goal.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Future<void> setGoalCompleted(
    String userId,
    String goalId,
    bool isCompleted,
  ) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .doc(goalId)
        .update({
      'isCompleted': isCompleted,
      'completedAt':
          isCompleted ? FieldValue.serverTimestamp() : FieldValue.delete(),
    });
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    final goalRef = _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_goalsCollection)
        .doc(goalId);

    final tasksSnap = await goalRef.collection(_tasksSubcollection).get();
    for (final doc in tasksSnap.docs) {
      await doc.reference.delete();
    }
    await goalRef.delete();
  }
}

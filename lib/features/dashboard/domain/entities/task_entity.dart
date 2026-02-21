import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_entity.freezed.dart';

/// Task entity for dashboard/insights (stored in Firestore under goals).
@freezed
class TaskEntity with _$TaskEntity {
  const TaskEntity._();
  const factory TaskEntity({
    required String id,
    required String goalId,
    required String title,
    required String dueDate,
    @Default(false) bool completed,
    @Default(0) int order,
    DateTime? completedAt,
  }) = _TaskEntity;

  factory TaskEntity.fromFirestore(Map<String, dynamic> map, String id) {
    return TaskEntity(
      id: id,
      goalId: map['goalId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      dueDate: map['dueDate'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'goalId': goalId,
        'title': title,
        'dueDate': dueDate,
        'completed': completed,
        'order': order,
        'completedAt': completedAt?.toIso8601String(),
      };
}

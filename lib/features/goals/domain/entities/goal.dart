import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

/// Goal entity (domain).
@freezed
class Goal with _$Goal {
  const Goal._();
  const factory Goal({
    required String id,
    required String userId,
    required String title,
    required String deadlineDate,
    /// Creation timestamp. Can be `null` for older documents.
    DateTime? createdAt,
    /// Whether the goal is completed.
    ///
    /// Stored as a Firestore `bool` and defaults to `false` for legacy
    /// documents that do not have the field yet.
    @Default(false) bool isCompleted,
    /// Optional cached progress percentage for the goal as a value between
    /// 0.0 and 1.0. Existing documents may not contain this field.
    double? progress,
  }) = _Goal;

  factory Goal.fromFirestore(Map<String, dynamic> map, String id) {
    // The original mapping assumed createdAt was always stored as an ISO
    // string. After switching to serverTimestamp in Firestore, we need to
    // handle both Timestamp and String to avoid runtime type errors when
    // reading back goals.
    final createdAtRaw = map['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    final isCompletedRaw = map['isCompleted'];
    final progressRaw = map['progress'];

    return Goal(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      deadlineDate: map['deadlineDate'] as String? ?? '',
      createdAt: createdAt,
      isCompleted: isCompletedRaw is bool ? isCompletedRaw : false,
      progress: progressRaw is num ? progressRaw.toDouble() : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        // Keep the original deadlineDate string for existing consumers,
        // while the repository also writes a proper DateTime "deadline"
        // field to match the Firestore schema requirements.
        'deadlineDate': deadlineDate,
        'createdAt': createdAt?.toIso8601String(),
        'isCompleted': isCompleted,
        if (progress != null) 'progress': progress,
      };
}

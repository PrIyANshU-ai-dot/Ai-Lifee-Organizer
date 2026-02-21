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
    DateTime? createdAt,
  }) = _Goal;

  factory Goal.fromFirestore(Map<String, dynamic> map, String id) {
    return Goal(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      deadlineDate: map['deadlineDate'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'deadlineDate': deadlineDate,
        'createdAt': createdAt?.toIso8601String(),
      };
}

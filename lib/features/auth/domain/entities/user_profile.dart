import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// User profile stored in Firestore (domain entity).
@freezed
class UserProfile with _$UserProfile {
  const UserProfile._();
  const factory UserProfile({
    required String id,
    required String email,
    @Default('') String displayName,
    DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromFirestore(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt?.toIso8601String(),
      };
}

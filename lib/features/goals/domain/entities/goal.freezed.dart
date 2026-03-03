// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Goal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get deadlineDate => throw _privateConstructorUsedError;

  /// Creation timestamp. Can be `null` for older documents.
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Whether the goal is completed.
  ///
  /// Stored as a Firestore `bool` and defaults to `false` for legacy
  /// documents that do not have the field yet.
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Optional cached progress percentage for the goal as a value between
  /// 0.0 and 1.0. Existing documents may not contain this field.
  double? get progress => throw _privateConstructorUsedError;

  /// Create a copy of Goal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalCopyWith<Goal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalCopyWith<$Res> {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) then) =
      _$GoalCopyWithImpl<$Res, Goal>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String deadlineDate,
    DateTime? createdAt,
    bool isCompleted,
    double? progress,
  });
}

/// @nodoc
class _$GoalCopyWithImpl<$Res, $Val extends Goal>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Goal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? deadlineDate = null,
    Object? createdAt = freezed,
    Object? isCompleted = null,
    Object? progress = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            deadlineDate: null == deadlineDate
                ? _value.deadlineDate
                : deadlineDate // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoalImplCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$$GoalImplCopyWith(
    _$GoalImpl value,
    $Res Function(_$GoalImpl) then,
  ) = __$$GoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String deadlineDate,
    DateTime? createdAt,
    bool isCompleted,
    double? progress,
  });
}

/// @nodoc
class __$$GoalImplCopyWithImpl<$Res>
    extends _$GoalCopyWithImpl<$Res, _$GoalImpl>
    implements _$$GoalImplCopyWith<$Res> {
  __$$GoalImplCopyWithImpl(_$GoalImpl _value, $Res Function(_$GoalImpl) _then)
    : super(_value, _then);

  /// Create a copy of Goal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? deadlineDate = null,
    Object? createdAt = freezed,
    Object? isCompleted = null,
    Object? progress = freezed,
  }) {
    return _then(
      _$GoalImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        deadlineDate: null == deadlineDate
            ? _value.deadlineDate
            : deadlineDate // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$GoalImpl extends _Goal {
  const _$GoalImpl({
    required this.id,
    required this.userId,
    required this.title,
    required this.deadlineDate,
    this.createdAt,
    this.isCompleted = false,
    this.progress,
  }) : super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String deadlineDate;

  /// Creation timestamp. Can be `null` for older documents.
  @override
  final DateTime? createdAt;

  /// Whether the goal is completed.
  ///
  /// Stored as a Firestore `bool` and defaults to `false` for legacy
  /// documents that do not have the field yet.
  @override
  @JsonKey()
  final bool isCompleted;

  /// Optional cached progress percentage for the goal as a value between
  /// 0.0 and 1.0. Existing documents may not contain this field.
  @override
  final double? progress;

  @override
  String toString() {
    return 'Goal(id: $id, userId: $userId, title: $title, deadlineDate: $deadlineDate, createdAt: $createdAt, isCompleted: $isCompleted, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.deadlineDate, deadlineDate) ||
                other.deadlineDate == deadlineDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    deadlineDate,
    createdAt,
    isCompleted,
    progress,
  );

  /// Create a copy of Goal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalImplCopyWith<_$GoalImpl> get copyWith =>
      __$$GoalImplCopyWithImpl<_$GoalImpl>(this, _$identity);
}

abstract class _Goal extends Goal {
  const factory _Goal({
    required final String id,
    required final String userId,
    required final String title,
    required final String deadlineDate,
    final DateTime? createdAt,
    final bool isCompleted,
    final double? progress,
  }) = _$GoalImpl;
  const _Goal._() : super._();

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get deadlineDate;

  /// Creation timestamp. Can be `null` for older documents.
  @override
  DateTime? get createdAt;

  /// Whether the goal is completed.
  ///
  /// Stored as a Firestore `bool` and defaults to `false` for legacy
  /// documents that do not have the field yet.
  @override
  bool get isCompleted;

  /// Optional cached progress percentage for the goal as a value between
  /// 0.0 and 1.0. Existing documents may not contain this field.
  @override
  double? get progress;

  /// Create a copy of Goal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalImplCopyWith<_$GoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

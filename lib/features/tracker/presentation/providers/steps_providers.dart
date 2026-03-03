import 'dart:async';

import 'package:ai_life_organizer/features/tracker/data/repositories/mock_steps_repository_impl.dart';
import 'package:ai_life_organizer/features/tracker/data/repositories/pedometer_steps_repository_impl.dart';
import 'package:ai_life_organizer/features/tracker/domain/entities/steps_history_entry.dart';
import 'package:ai_life_organizer/features/tracker/domain/repositories/steps_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository selector.
///
/// Design note:
/// - Keeps a single `StepsRepository` dependency for the UI.
/// - Falls back to mock if the sensor stream fails at runtime.
final stepsRepositoryProvider = Provider<StepsRepository>((ref) {
  return const PedometerStepsRepositoryImpl();
});

final stepsPermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ref.read(stepsRepositoryProvider).requestPermission();
});

final todayStepsProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.read(stepsRepositoryProvider);

  // If the pedometer stream throws (permissions/device), we fall back to mock to
  // avoid a blank screen.
  return repo.watchTodaySteps().onErrorResume(
        (error, stack) => MockStepsRepositoryImpl().watchTodaySteps(),
      );
});

final stepsHistoryProvider =
    FutureProvider.autoDispose.family<List<StepsHistoryEntry>, int>((ref, days) async {
  final repo = ref.read(stepsRepositoryProvider);
  try {
    return await repo.fetchHistory(days: days);
  } catch (_) {
    return await MockStepsRepositoryImpl().fetchHistory(days: days);
  }
});

extension _StreamResume<T> on Stream<T> {
  Stream<T> onErrorResume(Stream<T> Function(Object, StackTrace) resume) {
    late StreamController<T> controller;
    StreamSubscription<T>? sub;

    controller = StreamController<T>(
      onListen: () {
        sub = listen(
          controller.add,
          onError: (Object e, StackTrace st) async {
            await sub?.cancel();
            resume(e, st).listen(
              controller.add,
              onError: controller.addError,
              onDone: controller.close,
            );
          },
          onDone: controller.close,
        );
      },
      onCancel: () async => sub?.cancel(),
    );

    return controller.stream;
  }
}


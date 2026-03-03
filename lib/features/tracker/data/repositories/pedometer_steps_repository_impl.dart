import 'dart:async';

import 'package:ai_life_organizer/features/tracker/domain/entities/steps_history_entry.dart';
import 'package:ai_life_organizer/features/tracker/domain/repositories/steps_repository.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Sensor-backed steps repository using the `pedometer` plugin.
///
/// Important note:
/// - Pedometer APIs generally provide cumulative steps since device boot.
///   For this MVP we surface the raw number as "today" steps and rely on UI
///   to communicate "best effort". A production implementation would store a
///   daily baseline and compute per-day deltas.
class PedometerStepsRepositoryImpl implements StepsRepository {
  const PedometerStepsRepositoryImpl();

  @override
  Future<bool> requestPermission() async {
    // Android 10+ requires ACTIVITY_RECOGNITION. iOS permissions are handled by
    // the OS; the plugin may still throw if motion access is denied.
    final status = await Permission.activityRecognition.request();
    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> isSensorAvailable() async {
    // The plugin doesn't expose an explicit capability check. We treat the
    // ability to subscribe as "available" and fall back to mock on errors.
    return true;
  }

  @override
  Stream<int> watchTodaySteps() {
    return Pedometer.stepCountStream
        .map((event) => event.steps)
        .handleError((e, st) {
      // Let the caller decide how to handle; providers will swap to mock.
      // ignore: avoid_print
      print('[PedometerStepsRepositoryImpl] step stream error: $e\n$st');
      throw e;
    });
  }

  @override
  Future<List<StepsHistoryEntry>> fetchHistory({int days = 7}) async {
    // The pedometer plugin doesn't provide historical step data. We return
    // mock history so the screen has a consistent UX.
    return List<StepsHistoryEntry>.generate(
      days,
      (i) => StepsHistoryEntry(
        dateLabel: i == 0 ? 'Today' : '${i}d ago',
        steps: 0,
      ),
    );
  }
}


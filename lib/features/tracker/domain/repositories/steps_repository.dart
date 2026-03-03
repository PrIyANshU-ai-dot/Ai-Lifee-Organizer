import 'package:ai_life_organizer/features/tracker/domain/entities/steps_history_entry.dart';

/// Domain repository for step tracking.
///
/// Design decision:
/// - Keeps pedometer/health plugin details out of the presentation layer.
/// - Allows a mock implementation when sensors/permissions are unavailable.
abstract class StepsRepository {
  /// Requests any runtime permission needed for step counting.
  ///
  /// Returns true if the app has (or already had) permission.
  Future<bool> requestPermission();

  /// Whether the current platform/device can stream step counts.
  Future<bool> isSensorAvailable();

  /// Stream of today's steps (best effort; plugin implementations may vary).
  Stream<int> watchTodaySteps();

  /// Mockable daily history used for UI list.
  Future<List<StepsHistoryEntry>> fetchHistory({int days = 7});
}


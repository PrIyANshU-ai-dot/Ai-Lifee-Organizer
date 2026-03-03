import 'dart:async';
import 'dart:math';

import 'package:ai_life_organizer/features/tracker/domain/entities/steps_history_entry.dart';
import 'package:ai_life_organizer/features/tracker/domain/repositories/steps_repository.dart';

/// Mock implementation used when sensors or permissions are unavailable.
class MockStepsRepositoryImpl implements StepsRepository {
  final _rand = Random();

  @override
  Future<bool> isSensorAvailable() async => false;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Stream<int> watchTodaySteps() async* {
    var steps = 1200 + _rand.nextInt(400);
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      steps += 3 + _rand.nextInt(15);
      yield steps;
    }
  }

  @override
  Future<List<StepsHistoryEntry>> fetchHistory({int days = 7}) async {
    final out = <StepsHistoryEntry>[];
    for (var i = 0; i < days; i++) {
      out.add(
        StepsHistoryEntry(
          dateLabel: i == 0 ? 'Today' : '${i}d ago',
          steps: 2400 + _rand.nextInt(6500),
        ),
      );
    }
    return out;
  }
}


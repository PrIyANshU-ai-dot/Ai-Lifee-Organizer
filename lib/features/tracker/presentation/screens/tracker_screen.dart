import 'package:ai_life_organizer/features/tracker/domain/entities/steps_history_entry.dart';
import 'package:ai_life_organizer/features/tracker/presentation/providers/steps_providers.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tracker screen (Steps Counter).
///
/// UX goals:
/// - Always show *something* (mock fallback) so the feature feels responsive.
/// - Still surface permissions status clearly so real sensor data can work.
class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  static const int _dailyGoal = 8000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(stepsPermissionProvider);
    final stepsAsync = ref.watch(todayStepsProvider);
    final historyAsync = ref.watch(stepsHistoryProvider(7));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Today's activity",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    stepsAsync.when(
                      loading: () => const LoadingOverlay(message: 'Reading steps...'),
                      error: (e, _) => Text('Error: $e'),
                      data: (steps) {
                        final progress =
                            (steps / _dailyGoal).clamp(0.0, 1.0).toDouble();
                        final calories = (steps * 0.04).round();
                        return Row(
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(progress * 100).round()}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'of $_dailyGoal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$steps steps',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Approx. $calories kcal burned'),
                                  const SizedBox(height: 8),
                                  permissionAsync.when(
                                    loading: () => const SizedBox.shrink(),
                                    error: (e, _) => Text('Permission error: $e'),
                                    data: (granted) {
                                      if (granted) {
                                        return Text(
                                          'Tracking with device sensors',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Permission is required to read steps on some devices.',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              // Trigger re-evaluation after the permission prompt.
                                              ref.invalidate(
                                                  stepsPermissionProvider);
                                              ref.invalidate(todayStepsProvider);
                                            },
                                            icon: const Icon(Icons.security),
                                            label:
                                                const Text('Request permission'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              loading: () => const LoadingOverlay(message: 'Loading history...'),
              error: (e, _) => Text('Error: $e'),
              data: (items) {
                if (items.isEmpty) {
                  return const Card(
                    child: ListTile(
                      title: Text('No history yet'),
                      subtitle: Text('Walk a bit and come back.'),
                    ),
                  );
                }

                final streak = _computeStreak(items);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly steps',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: BarChart(
                                BarChartData(
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 20,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= items.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Text(
                                            items[index].dateLabel[0],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    for (var i = 0; i < items.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: items[i].steps.toDouble(),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            width: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.local_fire_department_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Streak'),
                        subtitle: Text('$streak days in a row'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (final item in items)
                          Card(
                            child: ListTile(
                              title: Text(item.dateLabel),
                              trailing: Text(
                                '${item.steps}',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

int _computeStreak(List<StepsHistoryEntry> items) {
  var streak = 0;
  for (final item in items) {
    if (item.steps > 0) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}


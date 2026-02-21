import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/dashboard/domain/repositories/tasks_repository.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';

/// Insights: total tasks, completed, completion %, bar chart (fl_chart).
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not signed in')));
        }
        return _InsightsContent(userId: user.id);
      },
      loading: () => const Scaffold(body: LoadingOverlay()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _InsightsContent extends ConsumerWidget {
  const _InsightsContent({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(tasksStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: statsAsync.when(
          data: (stats) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatCard(
                    title: 'Total tasks',
                    value: '${stats.total}',
                    icon: Icons.list_alt,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Completed',
                    value: '${stats.completed}',
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Completion',
                    value: '${stats.completionPercentage.toStringAsFixed(1)}%',
                    icon: Icons.percent,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.total > 0 ? stats.total.toDouble() + 2 : 10,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = ['Total', 'Done'];
                                final i = value.toInt();
                                if (i >= 0 && i < labels.length) {
                                  return Text(labels[i]);
                                }
                                return const SizedBox();
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) =>
                                  Text(value.toInt().toString()),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: stats.total.toDouble(),
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                            showingTooltipIndicators: [],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: stats.completed.toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                            showingTooltipIndicators: [],
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LoadingOverlay(),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

final tasksStatsProvider = StreamProvider.autoDispose.family<TasksStats, String>((ref, userId) {
  return ref.read(tasksRepositoryProvider).watchTasksStats(userId);
});
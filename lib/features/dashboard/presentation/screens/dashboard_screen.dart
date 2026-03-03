import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_life_organizer/core/utils/date_utils.dart';
import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';
import 'package:ai_life_organizer/features/goals/presentation/providers/goals_providers.dart';
import 'package:ai_life_organizer/features/dashboard/domain/entities/task_entity.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/shared/widgets/empty_state.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';

/// Dashboard: today's tasks, circular progress, mark complete, real-time Firestore.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final todayStr = AppDateUtils.toStorageDate(DateTime.now());

    return userAsync.when<Widget>(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Not signed in')),
          );
        }
        return _DashboardContent(userId: user.id, dateStr: todayStr);
      },
      loading: () => const Scaffold(body: LoadingOverlay()),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.userId, required this.dateStr});

  final String userId;
  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider((userId, dateStr)));
    final goalsAsync = ref.watch(currentUserGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.go('/insights'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'assistant':
                  context.push('/assistant');
                  break;
                case 'tracker':
                  context.push('/tracker');
                  break;
                case 'profile':
                  context.push('/profile');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'assistant',
                child: ListTile(
                  leading: Icon(Icons.chat_bubble_outline),
                  title: Text('AI Assistant'),
                ),
              ),
              PopupMenuItem(
                value: 'tracker',
                child: ListTile(
                  leading: Icon(Icons.directions_walk),
                  title: Text('Steps tracker'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                ),
              ),
            ],
          ),
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
        child: tasksAsync.when(
          data: (tasks) {
            final completed = tasks.where((t) => t.completed).length;

            final goals = goalsAsync.valueOrNull ?? <Goal>[];
            final todayGoals = goals
                .where((Goal g) => g.deadlineDate == dateStr)
                .toList();
            final todayCompletedGoals = todayGoals
                .where((Goal g) => g.isCompleted)
                .length;

            return RefreshIndicator(
              onRefresh: () async {},
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: _HeaderCard(
                        totalTasks: tasks.length,
                        completedTasks: completed,
                        todayGoals: todayGoals.length,
                        completedGoals: todayCompletedGoals,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _WeeklyGoalsChart(goals: goals),
                    ),
                  ),
                  if (tasks.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.task_alt,
                          message:
                              "No tasks for today.\nCreate a goal to generate tasks.",
                          actionLabel: 'Create goal',
                          onAction: () => context.push('/goals/create'),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _TaskTile(
                          task: tasks[index],
                          onToggle: () => _toggleTask(ref, tasks[index]),
                        ),
                        childCount: tasks.length,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/create'),
        icon: const Icon(Icons.add),
        label: const Text('Goal'),
      ),
    );
  }

  void _toggleTask(WidgetRef ref, TaskEntity task) {
    ref.read(tasksRepositoryProvider).setTaskCompleted(
      userId,
      task.goalId,
      task.id,
      !task.completed,
    );
  }
}

class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({
    required this.totalTasks,
    required this.completedTasks,
    required this.todayGoals,
    required this.completedGoals,
  });

  final int totalTasks;
  final int completedTasks;
  final int todayGoals;
  final int completedGoals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final name = (user?.displayName.isNotEmpty == true
            ? user!.displayName
            : user?.email ?? 'You')
        .split(' ')
        .first;

    final progress =
        totalTasks == 0 ? 0.0 : completedTasks / totalTasks.toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalTasks == 0
                      ? 'No tasks planned for today.'
                      : 'You have $totalTasks tasks today.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedTasks of $totalTasks tasks done',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor:
                      Theme.of(context).colorScheme.onPrimary.withValues(
                            alpha: 0.2,
                          ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  todayGoals == 0
                      ? 'No goals due today.'
                      : '$completedGoals of $todayGoals goals due today completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimary.withValues(
                        alpha: 0.2,
                      ),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalsChart extends StatelessWidget {
  const _WeeklyGoalsChart({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bars = <BarChartGroupData>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: i),
      );
      final key =
          AppDateUtils.toStorageDate(day); // yyyy-MM-dd like deadlineDate
      final dayGoals =
          goals.where((g) => g.deadlineDate == key).toList();
      final total = dayGoals.length;
      final completed =
          dayGoals.where((g) => g.isCompleted).length;
      final ratio =
          total == 0 ? 0.0 : completed / total.toDouble();

      final x = 6 - i;
      bars.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: (ratio * 100).clamp(0, 100),
              borderRadius: BorderRadius.circular(6),
              width: 12,
              color: colorScheme.primary,
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Weekly goals progress',
              style: theme.textTheme.titleMedium,
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
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final date = DateTime(now.year, now.month, now.day)
                              .subtract(Duration(days: 6 - index));
                          final label = [
                            'M',
                            'T',
                            'W',
                            'T',
                            'F',
                            'S',
                            'S',
                          ][date.weekday - 1];
                          return Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: bars,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onToggle});

  final TaskEntity task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        onTap: onToggle,
      ),
    );
  }
}

/// Provider for today's tasks (real-time stream).
final todayTasksProvider =
    StreamProvider.autoDispose.family<List<TaskEntity>, (String, String)>((ref, params) {
  final (userId, dateStr) = params;
  return ref.read(tasksRepositoryProvider).watchTasksForDate(userId, dateStr);
});

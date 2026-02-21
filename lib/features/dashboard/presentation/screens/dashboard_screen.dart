import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_life_organizer/core/utils/date_utils.dart';
import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => context.go('/insights'),
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
            if (tasks.isEmpty) {
              return EmptyState(
                icon: Icons.task_alt,
                message: "No tasks for today.\nCreate a goal to generate tasks.",
                actionLabel: 'Create goal',
                onAction: () => context.push('/goals/create'),
              );
            }
            final completed = tasks.where((t) => t.completed).length;
            final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;

            return RefreshIndicator(
              onRefresh: () async {},
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _ProgressCard(
                        completed: completed,
                        total: tasks.length,
                        progress: progress,
                      ),
                    ),
                  ),
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
          task.goalId,
          task.id,
          !task.completed,
        );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed / $total completed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
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

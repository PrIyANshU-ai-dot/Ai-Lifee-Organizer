import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/goals/domain/entities/goal.dart';
import 'package:ai_life_organizer/features/goals/presentation/providers/goals_providers.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/router/app_router.dart';
import 'package:ai_life_organizer/shared/widgets/empty_state.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Goals overview screen.
///
/// - Shows all goals for the current user.
/// - Each goal has a progress indicator and completion toggle.
/// - Overdue goals are highlighted using the error color.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final goalsAsync = ref.watch(currentUserGoalsProvider);

    return userAsync.when(
      loading: () => const LoadingOverlay(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Not signed in'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Goals'),
          ),
          body: goalsAsync.when(
            loading: () => const LoadingOverlay(message: 'Loading goals...'),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (goals) {
              if (goals.isEmpty) {
                return EmptyState(
                  icon: Icons.flag_outlined,
                  message: "No goals yet.\nCreate your first goal to get started.",
                  actionLabel: 'Create goal',
                  onAction: () => context.push(AppRoutes.createGoal),
                );
              }

              final now = DateTime.now();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final isOverdue = _isOverdue(goal, now);
                  final progress = (goal.progress ?? 0).clamp(0, 1).toDouble();

                  return Dismissible(
                    key: ValueKey(goal.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete goal?'),
                              content: const Text(
                                'This will remove the goal and its tasks. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) {
                      ref
                          .read(goalsRepositoryProvider)
                          .deleteGoal(user.id, goal.id);
                    },
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: _GoalCompletionToggle(
                          goal: goal,
                          userId: user.id,
                        ),
                        title: Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: goal.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOverdue
                                  ? 'Overdue'
                                  : 'Due ${goal.deadlineDate}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isOverdue
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.createGoal),
            icon: const Icon(Icons.add),
            label: const Text('Goal'),
          ),
        );
      },
    );
  }

  bool _isOverdue(Goal goal, DateTime now) {
    // deadlineDate is stored as yyyy-MM-dd. Older documents may contain other
    // formats; we treat parsing failures as "not overdue" to be safe.
    try {
      final date = DateTime.parse(goal.deadlineDate);
      return date.isBefore(DateTime(now.year, now.month, now.day)) &&
          !goal.isCompleted;
    } catch (_) {
      return false;
    }
  }
}

class _GoalCompletionToggle extends ConsumerStatefulWidget {
  const _GoalCompletionToggle({
    required this.goal,
    required this.userId,
  });

  final Goal goal;
  final String userId;

  @override
  ConsumerState<_GoalCompletionToggle> createState() =>
      _GoalCompletionToggleState();
}

class _GoalCompletionToggleState extends ConsumerState<_GoalCompletionToggle>
    with SingleTickerProviderStateMixin {
  late bool _completed;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _completed = widget.goal.isCompleted;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: _completed ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _GoalCompletionToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal.isCompleted != widget.goal.isCompleted) {
      _completed = widget.goal.isCompleted;
      if (_completed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        final next = !_completed;
        setState(() {
          _completed = next;
          if (next) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
        await ref
            .read(goalsRepositoryProvider)
            .setGoalCompleted(widget.userId, widget.goal.id, next);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                colorScheme.surface,
                colorScheme.primary,
                t,
              ),
              boxShadow: [
                if (t > 0)
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Icon(
              _completed ? Icons.check : Icons.circle_outlined,
              size: 18,
              color: _completed ? colorScheme.onPrimary : colorScheme.outline,
            ),
          );
        },
      ),
    );
  }
}


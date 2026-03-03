import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/goals/presentation/providers/goals_providers.dart';
import 'package:ai_life_organizer/features/settings/presentation/providers/theme_providers.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:ai_life_organizer/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile screen: shows basic user info + quick stats.
///
/// Stats are intentionally lightweight:
/// - Goals count comes from the goals stream (real Firestore data).
/// - Productivity stats are mocked for now to avoid introducing new backend
///   queries while we keep the existing architecture stable.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final goalsAsync = ref.watch(currentUserGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GradientBackground(
        child: userAsync.when(
          loading: () => const LoadingOverlay(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Not signed in'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (user.displayName.isNotEmpty
                                  ? user.displayName
                                  : user.email)
                              .trim()
                              .characters
                              .first
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(
                        user.displayName.isNotEmpty ? user.displayName : 'User',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(user.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: SwitchListTile(
                      title: const Text('Theme'),
                      subtitle: const Text('Light / Dark / System'),
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (isDark) {
                        ref.read(themeModeProvider.notifier).state =
                            isDark ? ThemeMode.dark : ThemeMode.light;
                      },
                      secondary: const Icon(Icons.brightness_6_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  goalsAsync.when(
                    loading: () =>
                        const LoadingOverlay(message: 'Loading goals...'),
                    error: (e, _) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('Goals'),
                        subtitle: Text('Error: $e'),
                      ),
                    ),
                    data: (goals) => _StatTile(
                      icon: Icons.flag_outlined,
                      title: 'Goals',
                      value: '${goals.length}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GoogleStatusTile(userEmail: user.email),
                  const SizedBox(height: 12),
                  const _StatTile(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Streak',
                    value: '5 days (mock)',
                  ),
                  const SizedBox(height: 12),
                  const _StatTile(
                    icon: Icons.auto_graph,
                    title: 'Productivity',
                    value: '82% (mock)',
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

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

class _GoogleStatusTile extends StatelessWidget {
  const _GoogleStatusTile({required this.userEmail});

  final String userEmail;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final providers = firebaseUser?.providerData ?? const [];
    final connectedToGoogle = providers.any(
      (p) => p.providerId == 'google.com',
    );

    return Card(
      child: ListTile(
        leading: Icon(
          connectedToGoogle
              ? Icons.link
              : Icons.link_off,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Google account'),
        subtitle: Text(
          connectedToGoogle
              ? 'Connected as $userEmail'
              : 'Not connected. You can sign in with Google from the login screen.',
        ),
      ),
    );
  }
}


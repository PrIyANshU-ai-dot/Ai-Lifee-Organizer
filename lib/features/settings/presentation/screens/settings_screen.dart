import 'package:ai_life_organizer/features/settings/presentation/providers/theme_providers.dart';
import 'package:ai_life_organizer/shared/providers/providers.dart';
import 'package:ai_life_organizer/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings screen: theme + mock toggles + account actions.
///
/// Design note:
/// - Notifications toggle is mocked (no backend / scheduling yet).
/// - Theme mode is stored in an in-memory provider (see `themeModeProvider`).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true; // mock

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
              child: SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Toggle app theme'),
                value: isDark,
                onChanged: (v) {
                  ref.read(themeModeProvider.notifier).state =
                      v ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Mock toggle (coming soon)'),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


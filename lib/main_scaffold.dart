import 'package:ai_life_organizer/core/widgets/base_scaffold.dart';
import 'package:ai_life_organizer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ai_life_organizer/features/goals/presentation/screens/goals_screen.dart';
import 'package:ai_life_organizer/features/profile/presentation/screens/profile_screen.dart';
import 'package:ai_life_organizer/features/tracker/presentation/screens/tracker_screen.dart';
import 'package:flutter/material.dart';

/// Main application scaffold with bottom navigation.
///
/// Design goals:
/// - Uses an [IndexedStack] so tab contents keep their state alive.
/// - Avoids rebuilding screens on tab switches by instantiating them once.
/// - Reuses the existing `BaseScaffold` so styling stays consistent.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardScreen(),
      // Goals screen tab is implemented in the goals feature module.
      GoalsScreen(),
      TrackerScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) {
              final selected = states.contains(WidgetState.selected);
              return theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              );
            },
          ),
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == _currentIndex) return;
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Goals',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_walk_outlined),
              selectedIcon: Icon(Icons.directions_walk),
              label: 'Tracker',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:ai_life_organizer/core/widgets/base_scaffold.dart';

/// Shell wrapper for authenticated routes.
/// Provides consistent layout structure. Individual screens can override
/// with their own AppBar, FAB, etc. using BaseScaffold.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.appBarTitle,
  });

  final Widget child;
  final bool showAppBar;
  final String? appBarTitle;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: showAppBar && appBarTitle != null
          ? AppBar(title: Text(appBarTitle!))
          : null,
      body: child,
    );
  }
}

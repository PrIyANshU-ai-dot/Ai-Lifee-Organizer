import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode for the whole app.
///
/// Design decision:
/// - Kept as a simple in-memory provider to avoid adding persistence dependencies
///   (e.g. shared_preferences) for this iteration.
/// - Still lives under a feature folder to keep a Clean Architecture-friendly
///   structure: settings owns user preferences.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);


import 'package:flutter/material.dart';

/// Shared [BuildContext] convenience getters.
extension BuildContextX on BuildContext {
  /// Current theme.
  ThemeData get theme => Theme.of(this);

  /// Current color scheme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Whether the active theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Pops the current route when possible.
  void maybePopSafe<T extends Object?>([T? result]) {
    if (Navigator.canPop(this)) {
      Navigator.pop<T>(this, result);
    }
  }
}

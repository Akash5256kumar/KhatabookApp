part of 'theme_bloc.dart';

/// Base event for [ThemeBloc].
sealed class ThemeEvent extends Equatable {
  /// Creates a theme event.
  const ThemeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the saved theme.
final class ThemeStarted extends ThemeEvent {
  /// Creates the event.
  const ThemeStarted();
}

/// Toggles between light and dark themes.
final class ThemeToggled extends ThemeEvent {
  /// Creates the event.
  const ThemeToggled();
}

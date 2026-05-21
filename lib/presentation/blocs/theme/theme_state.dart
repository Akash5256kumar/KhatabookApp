part of 'theme_bloc.dart';

/// Base state for [ThemeBloc].
sealed class ThemeState extends Equatable {
  /// Creates a theme state.
  const ThemeState({required this.themeMode});

  /// Active theme mode.
  final ThemeMode themeMode;

  @override
  List<Object?> get props => <Object?>[themeMode];
}

/// Initial theme state.
final class ThemeInitial extends ThemeState {
  /// Creates the state.
  const ThemeInitial() : super(themeMode: ThemeMode.system);
}

/// Loading theme state.
final class ThemeLoading extends ThemeState {
  /// Creates the state.
  const ThemeLoading({required super.themeMode});
}

/// Success theme state.
final class ThemeSuccess extends ThemeState {
  /// Creates the state.
  const ThemeSuccess({required super.themeMode});
}

/// Failure theme state.
final class ThemeFailure extends ThemeState {
  /// Creates the state.
  const ThemeFailure({
    required super.themeMode,
    required this.message,
  });

  /// Failure message.
  final String message;

  @override
  List<Object?> get props => <Object?>[themeMode, message];
}

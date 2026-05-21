part of 'profile_bloc.dart';

/// Base event for [ProfileBloc].
sealed class ProfileEvent extends Equatable {
  /// Creates the event.
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads profile data.
final class ProfileStarted extends ProfileEvent {
  /// Creates the event.
  const ProfileStarted();
}

/// Updates the current language.
final class ProfileLanguageChanged extends ProfileEvent {
  /// Creates the event.
  const ProfileLanguageChanged(this.languageCode);

  /// Selected language code.
  final String languageCode;

  @override
  List<Object?> get props => <Object?>[languageCode];
}

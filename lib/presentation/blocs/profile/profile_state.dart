part of 'profile_bloc.dart';

/// Base state for [ProfileBloc].
sealed class ProfileState extends Equatable {
  /// Creates the state.
  const ProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial profile state.
final class ProfileInitial extends ProfileState {
  /// Creates the state.
  const ProfileInitial();
}

/// Loading profile state.
final class ProfileLoading extends ProfileState {
  /// Creates the state.
  const ProfileLoading();
}

/// Success profile state.
final class ProfileSuccess extends ProfileState {
  /// Creates the state.
  const ProfileSuccess({
    required this.user,
    required this.languageCode,
  });

  /// Current user profile.
  final UserEntity user;

  /// Selected language code.
  final String languageCode;

  @override
  List<Object?> get props => <Object?>[user, languageCode];
}

/// Failure profile state.
final class ProfileFailure extends ProfileState {
  /// Creates the state.
  const ProfileFailure(this.message);

  /// User-friendly message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

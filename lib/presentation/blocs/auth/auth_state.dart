part of 'auth_bloc.dart';

/// Base state for [AuthBloc].
sealed class AuthState extends Equatable {
  /// Creates an auth state.
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

/// No operation in progress.
final class AuthInitial extends AuthState {
  /// Creates the state.
  const AuthInitial();
}

/// An async operation is running — disable all interactive controls.
final class AuthLoading extends AuthState {
  /// Creates the state.
  const AuthLoading();
}

/// OTP was sent successfully — navigate to the OTP verify screen.
final class AuthOtpSent extends AuthState {
  /// Creates the state.
  const AuthOtpSent({required this.phone});

  /// Phone number the OTP was dispatched to.
  final String phone;

  @override
  List<Object?> get props => <Object?>[phone];
}

/// OTP verified but no business profile exists — navigate to business setup.
final class AuthNeedsBusinessSetup extends AuthState {
  /// Creates the state.
  const AuthNeedsBusinessSetup({required this.phone});

  /// Phone used to verify the OTP.
  final String phone;

  @override
  List<Object?> get props => <Object?>[phone];
}

/// Session is valid and business profile is complete — navigate to home.
final class AuthSuccess extends AuthState {
  /// Creates the state.
  const AuthSuccess(this.session);

  /// Resolved session payload.
  final AuthSessionEntity session;

  @override
  List<Object?> get props => <Object?>[session];
}

/// An operation failed — show error snackbar.
final class AuthFailure extends AuthState {
  /// Creates the state.
  const AuthFailure(this.message);

  /// User-friendly error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Client-side validation failed — show inline field error.
final class AuthValidationError extends AuthState {
  /// Creates the state.
  const AuthValidationError(this.message);

  /// Validation message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

part of 'auth_bloc.dart';

/// Base event for [AuthBloc].
sealed class AuthEvent extends Equatable {
  /// Creates an auth event.
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Checks whether a valid session exists (called on splash).
final class AuthBootstrapRequested extends AuthEvent {
  /// Creates the event.
  const AuthBootstrapRequested();
}

/// Resets the BLoC back to [AuthInitial] (called when a screen mounts).
final class AuthFlowResetRequested extends AuthEvent {
  /// Creates the event.
  const AuthFlowResetRequested();
}

/// Requests an OTP be sent to [phone].
final class AuthSendOtpRequested extends AuthEvent {
  /// Creates the event.
  const AuthSendOtpRequested({required this.phone});

  /// 10-digit phone number without country code.
  final String phone;

  @override
  List<Object?> get props => <Object?>[phone];
}

/// Verifies the OTP entered by the user.
final class AuthVerifyOtpRequested extends AuthEvent {
  /// Creates the event.
  const AuthVerifyOtpRequested({required this.phone, required this.otp});

  /// Phone used during [AuthSendOtpRequested].
  final String phone;

  /// 6-digit OTP entered by the user.
  final String otp;

  @override
  List<Object?> get props => <Object?>[phone, otp];
}

/// Saves the full name and business name to complete first-time profile setup.
final class AuthSetupBusinessRequested extends AuthEvent {
  const AuthSetupBusinessRequested({
    required this.fullName,
    required this.businessName,
    this.location,
    this.shopType = 'general',
  });

  final String fullName;
  final String businessName;
  final String? location;
  final String shopType;

  @override
  List<Object?> get props => <Object?>[fullName, businessName, location, shopType];
}

/// Logs out the current user.
final class AuthLogoutRequested extends AuthEvent {
  /// Creates the event.
  const AuthLogoutRequested();
}

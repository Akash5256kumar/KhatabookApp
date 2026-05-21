import 'package:apna_business_app/domain/entities/user_entity.dart';

/// High-level authentication status used for routing decisions.
enum AuthStatus {
  /// First launch — show onboarding pages.
  onboarding,

  /// Fully authenticated with a business profile.
  authenticated,

  /// No active session — show phone login.
  unauthenticated,

  /// OTP verified but business profile not yet created.
  needsBusinessSetup,
}

/// Represents the current session state.
class AuthSessionEntity {
  /// Creates an immutable auth session entity.
  const AuthSessionEntity({
    required this.status,
    this.user,
  });

  final AuthStatus status;
  final UserEntity? user;
}

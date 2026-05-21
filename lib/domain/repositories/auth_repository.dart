import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:dartz/dartz.dart';

/// Contract for all authentication operations.
abstract interface class AuthRepository {
  /// Returns the current session from local storage, or [AuthStatus.unauthenticated].
  Future<Either<Failure, AuthSessionEntity>> getCurrentSession();

  /// Sends a one-time password to [phone].
  Future<Either<Failure, Unit>> sendOtp({required String phone});

  /// Verifies [otp] for [phone].
  ///
  /// Returns [AuthStatus.needsBusinessSetup] if this is the first login,
  /// [AuthStatus.authenticated] otherwise.
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Creates the user profile after first login.
  Future<Either<Failure, AuthSessionEntity>> setupBusiness({
    required String fullName,
    required String businessName,
    String? location,
    String shopType = 'general',
  });

  /// Clears the current session from local storage.
  Future<Either<Failure, Unit>> logout();
}

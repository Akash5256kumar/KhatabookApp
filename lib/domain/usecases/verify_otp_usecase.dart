import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Verifies the OTP and returns the resulting auth session.
class VerifyOtpUseCase {
  /// Creates the use case.
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, AuthSessionEntity>> call({
    required String phone,
    required String otp,
  }) {
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}

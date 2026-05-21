// Superseded by VerifyOtpUseCase + SetupBusinessUseCase.
// Kept as a stub so existing test helpers compile without modification.
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// @deprecated Use the OTP auth flow instead.
class RegisterUseCase {
  /// Creates the use case.
  RegisterUseCase(this._repository);

  // ignore: unused_field
  final AuthRepository _repository;

  /// Always returns [UnknownFailure] — use the OTP flow instead.
  Future<Either<Failure, AuthSessionEntity>> call({
    required String name,
    required String email,
    required String password,
  }) async =>
      const Left(UnknownFailure('Use the OTP auth flow'));
}

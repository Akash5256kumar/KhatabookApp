import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Requests an OTP to be sent to the given phone number.
class SendOtpUseCase {
  /// Creates the use case.
  SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call({required String phone}) {
    return _repository.sendOtp(phone: phone);
  }
}

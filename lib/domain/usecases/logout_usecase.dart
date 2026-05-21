import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Logs the user out.
class LogoutUseCase {
  /// Creates the use case.
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call() => _repository.logout();
}

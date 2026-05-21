import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads the current profile data.
class FetchProfileUseCase {
  /// Creates the use case.
  FetchProfileUseCase(this._repository);

  final HomeRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, UserEntity>> call() => _repository.fetchProfile();
}

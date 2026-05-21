import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/repositories/detail_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads detail data for an entity id.
class FetchDetailUseCase {
  /// Creates the use case.
  FetchDetailUseCase(this._repository);

  final DetailRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, DetailEntity>> call(String id) {
    return _repository.fetchDetail(id);
  }
}

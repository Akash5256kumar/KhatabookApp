import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads a paginated customers page.
class FetchCustomersUseCase {
  /// Creates the use case.
  FetchCustomersUseCase(this._repository);

  final HomeRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, CustomersPageResult>> call({required int page}) {
    return _repository.fetchCustomers(page: page);
  }
}

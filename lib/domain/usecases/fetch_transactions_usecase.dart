import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads transactions for a page.
class FetchTransactionsUseCase {
  /// Creates the use case.
  FetchTransactionsUseCase(this._repository);

  final HomeRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, TransactionsPageResult>> call({required int page}) {
    return _repository.fetchTransactions(page: page);
  }
}

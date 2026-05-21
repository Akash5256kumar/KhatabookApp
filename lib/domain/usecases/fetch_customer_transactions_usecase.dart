import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads paginated transactions for a single customer.
class FetchCustomerTransactionsUseCase {
  /// Creates the use case.
  FetchCustomerTransactionsUseCase(this._repository);

  final HomeRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, List<TransactionEntity>>> call({
    required String customerId,
    required int page,
  }) {
    return _repository.fetchCustomerTransactions(
      customerId: customerId,
      page: page,
    );
  }
}

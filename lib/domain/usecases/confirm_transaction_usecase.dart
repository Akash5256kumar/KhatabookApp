import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class ConfirmTransactionParams {
  const ConfirmTransactionParams({
    required this.pendingTransaction,
    this.customerId,
    this.customerName,
    this.customerPhone,
  });

  final Map<String, dynamic> pendingTransaction;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
}

/// Sends the confirmed transaction draft to the backend for recording.
class ConfirmTransactionUseCase {
  ConfirmTransactionUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatResult>> call(ConfirmTransactionParams params) {
    return _repository.confirmTransaction(
      pendingTransaction: params.pendingTransaction,
      customerId: params.customerId,
      customerName: params.customerName,
      customerPhone: params.customerPhone,
    );
  }
}

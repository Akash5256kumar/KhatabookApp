import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Confirms a customer after the backend requested clarification.
class ConfirmCustomerUseCase {
  ConfirmCustomerUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<Either<Failure, ChatResult>> call(ConfirmCustomerParams params) {
    return _chatRepository.confirmCustomer(
      customerId: params.customerId,
      customerName: params.customerName,
      customerPhone: params.customerPhone,
      pendingTransaction: params.pendingTransaction,
    );
  }
}

/// Parameters for [ConfirmCustomerUseCase].
class ConfirmCustomerParams extends Equatable {
  /// Selects an existing customer by ID.
  const ConfirmCustomerParams.existing({
    required int customerId,
    required Map<String, dynamic> pendingTransaction,
  }) : customerId = customerId,
       customerName = null,
       customerPhone = null,
       pendingTransaction = pendingTransaction;

  /// Creates or confirms a new customer with a phone number (or "skip").
  const ConfirmCustomerParams.newCustomer({
    required String customerName,
    required String customerPhone,
    required Map<String, dynamic> pendingTransaction,
  }) : customerId = null,
       customerName = customerName,
       customerPhone = customerPhone,
       pendingTransaction = pendingTransaction;

  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final Map<String, dynamic> pendingTransaction;

  @override
  List<Object?> get props =>
      [customerId, customerName, customerPhone, pendingTransaction];
}

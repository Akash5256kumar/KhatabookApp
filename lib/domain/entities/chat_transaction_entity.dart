import 'package:equatable/equatable.dart';

/// A single line-item inside a chat-assistant transaction.
class ChatTransactionItemEntity extends Equatable {
  const ChatTransactionItemEntity({
    required this.name,
    required this.quantity,
    this.unit,
    required this.ratePerUnit,
    required this.subtotal,
  });

  final String name;
  final double quantity;
  final String? unit;
  final double ratePerUnit;
  final double subtotal;

  @override
  List<Object?> get props => [name, quantity, unit, ratePerUnit, subtotal];
}

/// A single line-item in a transaction draft summary card.
class TransactionDraftItemEntity extends Equatable {
  const TransactionDraftItemEntity({
    required this.name,
    this.quantity,
    this.unit,
    this.ratePerUnit,
    this.subtotal = 0.0,
    this.priceSource = 'user',
  });

  final String name;
  final double? quantity;
  final String? unit;
  final double? ratePerUnit;
  final double subtotal;
  final String priceSource; // "inventory" | "user"

  bool get priceFromInventory => priceSource == 'inventory';

  @override
  List<Object?> get props =>
      [name, quantity, unit, ratePerUnit, subtotal, priceSource];
}

/// Transaction draft shown in the summary card before final confirmation.
class TransactionDraftEntity extends Equatable {
  const TransactionDraftEntity({
    required this.type,
    this.customerName,
    this.items = const [],
    this.totalAmount = 0.0,
    this.amountPaid = 0.0,
    this.pendingAmount = 0.0,
    this.isCredit = false,
    this.note,
  });

  final String type;
  final String? customerName;
  final List<TransactionDraftItemEntity> items;
  final double totalAmount;
  final double amountPaid;
  final double pendingAmount;
  final bool isCredit;
  final String? note;

  @override
  List<Object?> get props => [
        type,
        customerName,
        items,
        totalAmount,
        amountPaid,
        pendingAmount,
        isCredit,
        note,
      ];
}

/// A transaction record returned by the AI assistant in a chat response.
class ChatTransactionEntity extends Equatable {
  const ChatTransactionEntity({
    required this.type,
    required this.status,
    this.customerName,
    this.totalAmount,
    this.amountPaid,
    this.pendingAmount,
    this.customerTotalPending,
    required this.isCredit,
    required this.items,
    this.note,
    this.message,
  });

  final String type;
  final String status;
  final String? customerName;
  final double? totalAmount;
  final double? amountPaid;
  final double? pendingAmount;
  final double? customerTotalPending;
  final bool isCredit;
  final List<ChatTransactionItemEntity> items;
  final String? note;
  final String? message;

  @override
  List<Object?> get props => [
        type,
        status,
        customerName,
        totalAmount,
        amountPaid,
        pendingAmount,
        customerTotalPending,
        isCredit,
        items,
        note,
        message,
      ];
}

import 'package:equatable/equatable.dart';

/// A single line item inside an invoice.
class InvoiceItemEntity extends Equatable {
  /// Creates an invoice line item.
  const InvoiceItemEntity({
    required this.name,
    required this.quantity,
    required this.rate,
  });

  /// Product or service name.
  final String name;

  /// Number of units.
  final double quantity;

  /// Price per unit.
  final double rate;

  /// Computed line total.
  double get total => quantity * rate;

  @override
  List<Object?> get props => <Object?>[name, quantity, rate];
}

/// Payment status of the invoice.
enum InvoiceStatus { unpaid, partiallyPaid, paid }

/// A complete invoice shown in the invoice screen.
class InvoiceEntity extends Equatable {
  /// Creates an invoice entity.
  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.amountPaid,
    required this.pendingAmount,
    required this.status,
    required this.createdAt,
    this.dueDate,
  });

  /// Unique identifier.
  final String id;

  /// Human-readable invoice number (e.g. INV-001).
  final String invoiceNumber;

  /// Customer name.
  final String customerName;

  /// Customer phone.
  final String customerPhone;

  /// Line items (for display only — do not use their sum as the total).
  final List<InvoiceItemEntity> items;

  /// The authoritative transaction amount from the API.
  final double totalAmount;

  /// Amount already collected for this specific transaction.
  final double amountPaid;

  /// Remaining unpaid amount for this specific transaction (totalAmount - amountPaid).
  final double pendingAmount;

  /// Current payment status.
  final InvoiceStatus status;

  /// Date the invoice was created.
  final DateTime createdAt;

  /// Date the invoice is due (null when not set by the backend).
  final DateTime? dueDate;

  /// Always equals [totalAmount] — the raw API amount.
  double get grandTotal => totalAmount;

  @override
  List<Object?> get props => <Object?>[id, invoiceNumber, customerName];
}

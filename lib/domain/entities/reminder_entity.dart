import 'package:equatable/equatable.dart';

/// Supported reminder delivery types.
enum ReminderStatus { pending, sent, paid }

/// Represents a payment reminder for a customer.
class ReminderEntity extends Equatable {
  /// Creates a reminder entity.
  const ReminderEntity({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.canSendOnWhatsApp,
    this.validationMessage,
    this.lastSentAt,
    this.deliveryChannel = 'whatsapp',
  });

  /// Unique identifier.
  final String id;

  /// Display name of the customer.
  final String customerName;

  /// Phone number to send reminder to.
  final String? phone;

  /// Overdue or outstanding amount.
  final double amount;

  /// Date by which payment is expected.
  final DateTime dueDate;

  /// Current status of the reminder.
  final ReminderStatus status;

  /// Whether the reminder can be sent on WhatsApp right now.
  final bool canSendOnWhatsApp;

  /// User-facing validation feedback when sending is unavailable.
  final String? validationMessage;

  /// Timestamp of the latest WhatsApp reminder.
  final DateTime? lastSentAt;

  /// Delivery channel for this reminder.
  final String deliveryChannel;

  @override
  List<Object?> get props =>
      <Object?>[
        id,
        customerName,
        phone,
        amount,
        dueDate,
        status,
        canSendOnWhatsApp,
        validationMessage,
        lastSentAt,
        deliveryChannel,
      ];
}

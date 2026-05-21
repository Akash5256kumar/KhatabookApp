import 'package:apna_business_app/domain/entities/reminder_entity.dart';

/// Raw reminder item returned by the API.
class ReminderModel {
  /// Creates the model.
  const ReminderModel({
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

  /// Parses API JSON.
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] as String? ?? '',
      phone: json['phone'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueDate: DateTime.tryParse(json['due_date'] as String? ?? '') ??
          DateTime.now(),
      status: _mapStatus(json['status'] as String?),
      canSendOnWhatsApp: json['can_send_whatsapp'] as bool? ?? false,
      validationMessage: json['validation_message'] as String?,
      lastSentAt: DateTime.tryParse(json['last_sent_at'] as String? ?? ''),
      deliveryChannel: json['delivery_channel'] as String? ?? 'whatsapp',
    );
  }

  /// Stable identifier. This maps to the customer id on the backend.
  final String id;

  /// Customer display name.
  final String customerName;

  /// Customer phone number if available.
  final String? phone;

  /// Outstanding amount.
  final double amount;

  /// When this balance became due/outstanding.
  final DateTime dueDate;

  /// Current reminder status.
  final ReminderStatus status;

  /// Whether WhatsApp sending is currently allowed.
  final bool canSendOnWhatsApp;

  /// Validation feedback from the backend.
  final String? validationMessage;

  /// Timestamp of the last sent reminder.
  final DateTime? lastSentAt;

  /// Delivery channel name.
  final String deliveryChannel;

  /// Converts to the domain entity.
  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      customerName: customerName,
      phone: phone,
      amount: amount,
      dueDate: dueDate,
      status: status,
      canSendOnWhatsApp: canSendOnWhatsApp,
      validationMessage: validationMessage,
      lastSentAt: lastSentAt,
      deliveryChannel: deliveryChannel,
    );
  }

  static ReminderStatus _mapStatus(String? raw) {
    return switch (raw?.toLowerCase()) {
      'sent' => ReminderStatus.sent,
      'paid' => ReminderStatus.paid,
      _ => ReminderStatus.pending,
    };
  }
}

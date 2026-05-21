import 'package:apna_business_app/domain/entities/reminder_entity.dart';
import 'package:equatable/equatable.dart';

/// Result of sending a WhatsApp reminder.
class ReminderSendResultEntity extends Equatable {
  /// Creates the result entity.
  const ReminderSendResultEntity({
    required this.reminder,
    required this.message,
    required this.provider,
  });

  /// Updated reminder returned by the backend.
  final ReminderEntity reminder;

  /// Human-readable success message.
  final String message;

  /// Provider used by the backend.
  final String provider;

  @override
  List<Object?> get props => <Object?>[reminder, message, provider];
}

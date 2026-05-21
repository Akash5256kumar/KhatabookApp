import 'package:apna_business_app/domain/entities/reminder_entity.dart';
import 'package:equatable/equatable.dart';

/// Reminder screen payload returned by the backend.
class ReminderOverviewEntity extends Equatable {
  /// Creates the overview entity.
  const ReminderOverviewEntity({
    required this.reminders,
    required this.whatsAppAutoEnabled,
  });

  /// Pending reminders visible on the list screen.
  final List<ReminderEntity> reminders;

  /// Whether WhatsApp auto reminders are enabled.
  final bool whatsAppAutoEnabled;

  @override
  List<Object?> get props => <Object?>[reminders, whatsAppAutoEnabled];
}

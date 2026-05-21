import 'package:equatable/equatable.dart';

/// Result of updating reminder settings.
class ReminderSettingsEntity extends Equatable {
  /// Creates the settings result entity.
  const ReminderSettingsEntity({
    required this.whatsAppAutoEnabled,
    required this.message,
  });

  /// Current WhatsApp auto-reminder state.
  final bool whatsAppAutoEnabled;

  /// Human-readable backend message.
  final String message;

  @override
  List<Object?> get props => <Object?>[whatsAppAutoEnabled, message];
}

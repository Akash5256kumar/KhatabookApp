import 'package:apna_business_app/domain/entities/reminder_settings_entity.dart';

/// Response model for reminder settings updates.
class ReminderSettingsModel {
  /// Creates the model.
  const ReminderSettingsModel({
    required this.whatsAppAutoEnabled,
    required this.message,
  });

  /// Parses API JSON.
  factory ReminderSettingsModel.fromJson(Map<String, dynamic> json) {
    return ReminderSettingsModel(
      whatsAppAutoEnabled: json['whatsapp_auto_enabled'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  /// Current setting state.
  final bool whatsAppAutoEnabled;

  /// Human-readable backend message.
  final String message;

  /// Converts to the domain entity.
  ReminderSettingsEntity toEntity() {
    return ReminderSettingsEntity(
      whatsAppAutoEnabled: whatsAppAutoEnabled,
      message: message,
    );
  }
}

import 'package:apna_business_app/data/models/reminder_model.dart';
import 'package:apna_business_app/domain/entities/reminder_send_result_entity.dart';

/// Response model for a sent reminder.
class ReminderSendResultModel {
  /// Creates the result model.
  const ReminderSendResultModel({
    required this.reminder,
    required this.message,
    required this.provider,
  });

  /// Parses API JSON.
  factory ReminderSendResultModel.fromJson(Map<String, dynamic> json) {
    return ReminderSendResultModel(
      reminder: ReminderModel.fromJson(
        json['reminder'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      message: json['message'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
    );
  }

  /// Updated reminder returned by the backend.
  final ReminderModel reminder;

  /// Success message.
  final String message;

  /// Provider used by the backend.
  final String provider;

  /// Converts to the domain entity.
  ReminderSendResultEntity toEntity() {
    return ReminderSendResultEntity(
      reminder: reminder.toEntity(),
      message: message,
      provider: provider,
    );
  }
}

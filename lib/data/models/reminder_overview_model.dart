import 'package:apna_business_app/data/models/reminder_model.dart';
import 'package:apna_business_app/domain/entities/reminder_overview_entity.dart';

/// API payload for the reminder list screen.
class ReminderOverviewModel {
  /// Creates the overview model.
  const ReminderOverviewModel({
    required this.items,
    required this.whatsAppAutoEnabled,
  });

  /// Parses API JSON.
  factory ReminderOverviewModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => ReminderModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return ReminderOverviewModel(
      items: items,
      whatsAppAutoEnabled: json['whatsapp_auto_enabled'] as bool? ?? false,
    );
  }

  /// Reminder items.
  final List<ReminderModel> items;

  /// WhatsApp auto-reminder setting.
  final bool whatsAppAutoEnabled;

  /// Converts to the domain entity.
  ReminderOverviewEntity toEntity() {
    return ReminderOverviewEntity(
      reminders: items.map((ReminderModel item) => item.toEntity()).toList(growable: false),
      whatsAppAutoEnabled: whatsAppAutoEnabled,
    );
  }
}

import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/reminder_overview_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_send_result_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_settings_entity.dart';
import 'package:dartz/dartz.dart';

/// Contract for fetching and sending WhatsApp reminders.
abstract interface class ReminderRepository {
  /// Loads reminders and the WhatsApp auto-send preference.
  Future<Either<Failure, ReminderOverviewEntity>> fetchReminders();

  /// Updates the WhatsApp auto-send setting.
  Future<Either<Failure, ReminderSettingsEntity>> updateWhatsAppAutoSetting({
    required bool enabled,
  });

  /// Sends a WhatsApp reminder to a customer.
  Future<Either<Failure, ReminderSendResultEntity>> sendReminder({
    required String customerId,
    required String message,
  });
}

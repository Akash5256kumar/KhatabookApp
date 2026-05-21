import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/reminder_settings_entity.dart';
import 'package:apna_business_app/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Updates the WhatsApp auto-reminder preference.
class UpdateReminderSettingsUseCase {
  /// Creates the use case.
  UpdateReminderSettingsUseCase(this._repository);

  final ReminderRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, ReminderSettingsEntity>> call({
    required bool enabled,
  }) {
    return _repository.updateWhatsAppAutoSetting(enabled: enabled);
  }
}

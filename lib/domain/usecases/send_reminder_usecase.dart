import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/reminder_send_result_entity.dart';
import 'package:apna_business_app/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Sends a WhatsApp reminder.
class SendReminderUseCase {
  /// Creates the use case.
  SendReminderUseCase(this._repository);

  final ReminderRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, ReminderSendResultEntity>> call({
    required String customerId,
    required String message,
  }) {
    return _repository.sendReminder(
      customerId: customerId,
      message: message,
    );
  }
}

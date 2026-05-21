import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/reminder_overview_entity.dart';
import 'package:apna_business_app/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads WhatsApp reminders for the current business.
class FetchRemindersUseCase {
  /// Creates the use case.
  FetchRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, ReminderOverviewEntity>> call() {
    return _repository.fetchReminders();
  }
}

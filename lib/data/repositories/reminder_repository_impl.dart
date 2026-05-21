import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/remote/reminder_remote_datasource.dart';
import 'package:apna_business_app/domain/entities/reminder_overview_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_send_result_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_settings_entity.dart';
import 'package:apna_business_app/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Reminder repository implementation.
class ReminderRepositoryImpl implements ReminderRepository {
  /// Creates the repository.
  ReminderRepositoryImpl(this._remoteDataSource);

  final ReminderRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ReminderOverviewEntity>> fetchReminders() async {
    try {
      final response = await _remoteDataSource.fetchReminders();
      return Right(response.toEntity());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ReminderSendResultEntity>> sendReminder({
    required String customerId,
    required String message,
  }) async {
    try {
      final response = await _remoteDataSource.sendReminder(
        customerId: customerId,
        message: message,
      );
      return Right(response.toEntity());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ReminderSettingsEntity>> updateWhatsAppAutoSetting({
    required bool enabled,
  }) async {
    try {
      final response = await _remoteDataSource.updateWhatsAppAutoSetting(
        enabled: enabled,
      );
      return Right(response.toEntity());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

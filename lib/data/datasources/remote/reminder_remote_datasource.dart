import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/models/reminder_overview_model.dart';
import 'package:apna_business_app/data/models/reminder_send_result_model.dart';
import 'package:apna_business_app/data/models/reminder_settings_model.dart';
import 'package:dio/dio.dart';

/// Remote datasource for WhatsApp reminders.
class ReminderRemoteDataSource {
  /// Creates the remote datasource.
  ReminderRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Loads reminders and auto-send state.
  Future<ReminderOverviewModel> fetchReminders() async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/api/v1/reminders/',
      );
      return ReminderOverviewModel.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw _mapReminderException(exception);
    }
  }

  /// Updates the WhatsApp auto-reminder setting.
  Future<ReminderSettingsModel> updateWhatsAppAutoSetting({
    required bool enabled,
  }) async {
    try {
      final response = await _dioClient.dio.patch<Map<String, dynamic>>(
        '/api/v1/reminders/settings',
        data: <String, dynamic>{'whatsapp_auto_enabled': enabled},
      );
      return ReminderSettingsModel.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw _mapReminderException(exception);
    }
  }

  /// Sends a WhatsApp reminder.
  Future<ReminderSendResultModel> sendReminder({
    required String customerId,
    required String message,
  }) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/reminders/$customerId/send-whatsapp',
        data: <String, dynamic>{'message': message},
      );
      return ReminderSendResultModel.fromJson(
        response.data ?? <String, dynamic>{},
      );
    } on DioException catch (exception) {
      throw _mapReminderException(exception);
    }
  }

  AppException _mapReminderException(DioException exception) {
    final dynamic data = exception.response?.data;
    final String? detail = data is Map<String, dynamic>
        ? data['detail'] as String?
        : null;
    if (detail != null && detail.trim().isNotEmpty) {
      final int? statusCode = exception.response?.statusCode;
      if (statusCode == 404) {
        return NotFoundException(detail);
      }
      return ServerException(detail);
    }
    return mapDioException(exception);
  }
}

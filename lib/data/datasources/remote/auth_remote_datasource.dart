import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/models/otp_send_response_model.dart';
import 'package:apna_business_app/data/models/otp_verify_response_model.dart';
import 'package:apna_business_app/data/models/profile_setup_response_model.dart';
import 'package:apna_business_app/data/models/user_model.dart';
import 'package:dio/dio.dart';

/// Remote auth datasource that talks to the backend API.
class AuthRemoteDataSource {
  /// Creates the datasource.
  AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Sends a one-time password SMS to [phone].
  Future<OtpSendResponseModel> sendOtp({required String phone}) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/send-otp/',
        data: {
          'phone_number': phone,
          'purpose': 'login',
        },
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        throw const ServerException('Empty response from server');
      }

      return OtpSendResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Verifies [otp] for [phone].
  ///
  /// Returns the verification response.
  Future<OtpVerifyResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-otp/',
        data: {
          'phone_number': phone,
          'otp': otp,
          'purpose': 'login',
        },
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        throw const ServerException('Empty response from server');
      }

      return OtpVerifyResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Calls POST /api/v1/profile/setup to save full name and business name.
  ///
  /// Requires a valid Bearer token in the [Authorization] header — the
  /// [_AuthInterceptor] inside [DioClient] attaches it automatically from
  /// local storage.
  Future<UserModel> setupProfile({
    required String fullName,
    required String businessName,
    String? location,
    String shopType = 'general',
  }) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        'full_name': fullName,
        'business_name': businessName,
        'user_type': 'business',
        'shop_type': shopType,
      };
      if (location != null && location.trim().isNotEmpty) {
        payload['location'] = location.trim();
      }

      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/profile/setup',
        data: payload,
      );

      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        throw const ServerException('Empty response from server');
      }

      final model = ProfileSetupResponseModel.fromJson(data);
      return UserModel(
        id: model.userId.toString(),
        name: model.fullName,
        email: '',
        businessName: model.businessName,
        businessId: model.businessId,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

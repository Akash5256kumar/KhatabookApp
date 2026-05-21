/// DTO for verify OTP response.
class OtpVerifyResponseModel {
  /// Creates an OTP verify response model.
  const OtpVerifyResponseModel({
    required this.message,
    required this.verified,
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.isNewUser,
  });

  /// Human-readable server message.
  final String message;

  /// Whether the OTP verification was successful.
  final bool verified;

  /// Access token returned from the API.
  final String accessToken;

  /// The token type returned by the API.
  final String tokenType;

  /// The server-issued user ID.
  final int userId;

  /// Whether the user is new and needs business setup.
  final bool isNewUser;

  /// Creates an OTP verify response model from JSON.
  factory OtpVerifyResponseModel.fromJson(Map<String, Object?> json) {
    return OtpVerifyResponseModel(
      message: json['message'] as String,
      verified: json['verified'] as bool,
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      userId: (json['user_id'] as num).toInt(),
      isNewUser: json['is_new_user'] as bool,
    );
  }

  /// Converts the response model to JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'message': message,
      'verified': verified,
      'access_token': accessToken,
      'token_type': tokenType,
      'user_id': userId,
      'is_new_user': isNewUser,
    };
  }
}

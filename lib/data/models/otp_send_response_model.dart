/// DTO for send OTP response.
class OtpSendResponseModel {
  /// Creates an OTP send response model.
  const OtpSendResponseModel({
    required this.message,
    this.destination,
    required this.expiresInSeconds,
    this.debugOtp,
  });

  /// User-facing status message.
  final String message;

  /// Masked destination where the OTP was sent (may be absent).
  final String? destination;

  /// Expiration time in seconds.
  final int expiresInSeconds;

  /// Debug-only OTP value — only present in non-production environments.
  final String? debugOtp;

  /// Creates an OTP send response model from JSON.
  factory OtpSendResponseModel.fromJson(Map<String, Object?> json) {
    return OtpSendResponseModel(
      message: json['message'] as String,
      destination: json['destination'] as String?,
      expiresInSeconds: (json['expires_in_seconds'] as num? ?? 120).toInt(),
      debugOtp: json['debug_otp'] as String?,
    );
  }

  /// Converts the response model to JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'message': message,
      if (destination != null) 'destination': destination,
      'expires_in_seconds': expiresInSeconds,
      if (debugOtp != null) 'debug_otp': debugOtp,
    };
  }
}

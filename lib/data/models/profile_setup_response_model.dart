/// DTO for POST /api/v1/profile/setup response.
class ProfileSetupResponseModel {
  const ProfileSetupResponseModel({
    required this.message,
    required this.userId,
    required this.fullName,
    required this.businessId,
    required this.businessName,
  });

  final String message;
  final int userId;
  final String fullName;
  final int businessId;
  final String businessName;

  factory ProfileSetupResponseModel.fromJson(Map<String, Object?> json) {
    return ProfileSetupResponseModel(
      message: json['message'] as String,
      userId: (json['user_id'] as num).toInt(),
      fullName: json['full_name'] as String,
      businessId: (json['business_id'] as num).toInt(),
      businessName: json['business_name'] as String,
    );
  }
}

import 'package:apna_business_app/domain/entities/user_entity.dart';

/// DTO for the logged-in user.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.businessName,
    this.businessId,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? businessName;
  final int? businessId;

  factory UserModel.fromJson(Map<String, Object?> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      businessName: json['businessName'] as String?,
      businessId: json['businessId'] as int?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'businessName': businessName,
      'businessId': businessId,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      businessName: businessName,
    );
  }
}

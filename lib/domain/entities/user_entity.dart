import 'package:equatable/equatable.dart';

/// Represents the signed-in user in the domain layer.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.businessName,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? businessName;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, businessName];
}

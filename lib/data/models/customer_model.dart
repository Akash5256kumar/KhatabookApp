import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

/// DTO for customer list responses.
@freezed
class CustomerModel with _$CustomerModel {
  /// Creates a customer model.
  const factory CustomerModel({
    required String id,
    required String name,
    required String phone,
    required double balance,
    required DateTime updatedAt,
    String? avatarUrl,
    @Default(0.0) double totalSale,
    @Default(0.0) double totalReceived,
  }) = _CustomerModel;

  /// Creates a customer model from JSON.
  factory CustomerModel.fromJson(Map<String, Object?> json) =>
      _$CustomerModelFromJson(json);
}

/// Maps a [CustomerModel] to a [CustomerEntity].
extension CustomerModelX on CustomerModel {
  /// Converts the model to a domain entity.
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      phone: phone,
      balance: balance,
      updatedAt: updatedAt,
      avatarUrl: avatarUrl,
      totalSale: totalSale,
      totalReceived: totalReceived,
    );
  }
}

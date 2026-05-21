import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_entity.freezed.dart';

/// Represents a customer item in the app.
@freezed
class CustomerEntity with _$CustomerEntity {
  /// Creates an immutable customer entity.
  const factory CustomerEntity({
    required String id,
    required String name,
    required String phone,
    required double balance,
    required DateTime updatedAt,
    String? avatarUrl,
    @Default(0.0) double totalSale,
    @Default(0.0) double totalReceived,
  }) = _CustomerEntity;
}

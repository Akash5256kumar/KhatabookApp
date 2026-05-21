import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// DTO for transactions.
@freezed
class TransactionModel with _$TransactionModel {
  /// Creates a transaction model.
  const factory TransactionModel({
    required String id,
    required String customerName,
    required String title,
    required String subtitle,
    required String imageUrl,
    required double amount,
    required DateTime createdAt,
    required TransactionType type,
    required bool isPositive,
  }) = _TransactionModel;

  /// Creates a transaction model from JSON.
  factory TransactionModel.fromJson(Map<String, Object?> json) =>
      _$TransactionModelFromJson(json);
}

/// Maps a [TransactionModel] to a [TransactionEntity].
extension TransactionModelX on TransactionModel {
  /// Converts the model to a domain entity.
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      customerName: customerName,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      amount: amount,
      createdAt: createdAt,
      type: type,
      isPositive: isPositive,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

/// Supported transaction types shown in the app.
enum TransactionType { sale, payment, expense, credit }

/// Represents a transaction in lists and summaries.
@freezed
class TransactionEntity with _$TransactionEntity {
  /// Creates an immutable transaction entity.
  const factory TransactionEntity({
    required String id,
    required String customerName,
    required String title,
    required String subtitle,
    required String imageUrl,
    required double amount,
    required DateTime createdAt,
    required TransactionType type,
    required bool isPositive,
  }) = _TransactionEntity;
}

import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_entity.freezed.dart';

/// Full detail payload for the inner detail screen.
@freezed
class DetailEntity with _$DetailEntity {
  /// Creates an immutable detail entity.
  const factory DetailEntity({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String description,
    required double amount,
    required DateTime createdAt,
    required TransactionType type,
    required List<String> highlights,
  }) = _DetailEntity;
}

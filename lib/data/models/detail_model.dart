import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_model.freezed.dart';
part 'detail_model.g.dart';

/// DTO for detail responses.
@freezed
class DetailModel with _$DetailModel {
  /// Creates a detail model.
  const factory DetailModel({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String description,
    required double amount,
    required DateTime createdAt,
    required TransactionType type,
    required List<String> highlights,
  }) = _DetailModel;

  /// Creates a model from JSON.
  factory DetailModel.fromJson(Map<String, Object?> json) =>
      _$DetailModelFromJson(json);
}

/// Maps a [DetailModel] to a [DetailEntity].
extension DetailModelX on DetailModel {
  /// Converts the model to a domain entity.
  DetailEntity toEntity() {
    return DetailEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      description: description,
      amount: amount,
      createdAt: createdAt,
      type: type,
      highlights: highlights,
    );
  }
}

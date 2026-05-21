import 'package:apna_business_app/data/models/transaction_model.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_feed_model.freezed.dart';
part 'home_feed_model.g.dart';

/// DTO for a summary metric.
@freezed
class SummaryMetricModel with _$SummaryMetricModel {
  /// Creates a summary metric model.
  const factory SummaryMetricModel({
    required String title,
    required double amount,
    required String helperText,
  }) = _SummaryMetricModel;

  /// Creates a model from JSON.
  factory SummaryMetricModel.fromJson(Map<String, Object?> json) =>
      _$SummaryMetricModelFromJson(json);
}

/// DTO for home feed responses.
@freezed
class HomeFeedModel with _$HomeFeedModel {
  /// Creates a home feed model.
  const factory HomeFeedModel({
    required List<SummaryMetricModel> metrics,
    required List<TransactionModel> feedItems,
    required int page,
    required bool hasMore,
  }) = _HomeFeedModel;

  /// Creates a model from JSON.
  factory HomeFeedModel.fromJson(Map<String, Object?> json) =>
      _$HomeFeedModelFromJson(json);
}

/// Maps [SummaryMetricModel] and [HomeFeedModel] to entities.
extension HomeFeedModelX on HomeFeedModel {
  /// Converts the model to a domain entity.
  HomeFeedEntity toEntity() {
    return HomeFeedEntity(
      metrics: metrics
          .map(
            (SummaryMetricModel metric) => SummaryMetricEntity(
              title: metric.title,
              amount: metric.amount,
              helperText: metric.helperText,
            ),
          )
          .toList(growable: false),
      feedItems: feedItems
          .map((TransactionModel transaction) => transaction.toEntity())
          .toList(growable: false),
      page: page,
      hasMore: hasMore,
    );
  }
}

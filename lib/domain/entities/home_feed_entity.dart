import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_feed_entity.freezed.dart';

/// Summary card shown at the top of the dashboard.
@freezed
class SummaryMetricEntity with _$SummaryMetricEntity {
  /// Creates an immutable summary metric.
  const factory SummaryMetricEntity({
    required String title,
    required double amount,
    required String helperText,
  }) = _SummaryMetricEntity;
}

/// Combined home feed payload.
@freezed
class HomeFeedEntity with _$HomeFeedEntity {
  /// Creates an immutable dashboard payload.
  const factory HomeFeedEntity({
    required List<SummaryMetricEntity> metrics,
    required List<TransactionEntity> feedItems,
    required int page,
    required bool hasMore,
  }) = _HomeFeedEntity;
}

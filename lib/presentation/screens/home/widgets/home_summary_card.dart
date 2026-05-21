import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:flutter/material.dart';

/// Dashboard summary card.
class HomeSummaryCard extends StatelessWidget {
  /// Creates a summary card.
  const HomeSummaryCard({
    required this.metric,
    super.key,
  });

  /// Metric payload.
  final SummaryMetricEntity metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(metric.title, style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(metric.amount.toInr, style: AppTextStyles.amount),
            const SizedBox(height: AppDimensions.spaceXS),
            Text(
              metric.helperText,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

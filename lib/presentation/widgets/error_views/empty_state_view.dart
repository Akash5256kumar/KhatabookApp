import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared illustrated empty state.
class EmptyStateView extends StatelessWidget {
  /// Creates an empty state view.
  const EmptyStateView({
    required this.title,
    required this.message,
    super.key,
  });

  /// Title text.
  final String title;

  /// Supporting message.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              AppConstants.emptyStateAsset,
              height: 160,
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              message,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

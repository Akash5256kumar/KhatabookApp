import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared branded error view.
class BrandedErrorView extends StatelessWidget {
  /// Creates an error view.
  const BrandedErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// Message shown to the user.
  final String message;

  /// Retry callback.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              AppConstants.errorStateAsset,
              height: 160,
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            const Text(
              'Something went wrong',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              message,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            PrimaryButton(label: 'Try Again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

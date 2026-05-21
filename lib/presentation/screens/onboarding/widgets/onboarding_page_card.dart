import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Presentational onboarding page.
class OnboardingPageCard extends StatelessWidget {
  /// Creates an onboarding page card.
  const OnboardingPageCard({
    required this.assetPath,
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// Illustration asset path.
  final String assetPath;

  /// Title text.
  final String title;

  /// Subtitle text.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            assetPath,
            height: AppDimensions.onboardingIllustrationHeight,
          ),
          const SizedBox(height: AppDimensions.space3XL),
          Text(
            title,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            subtitle,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

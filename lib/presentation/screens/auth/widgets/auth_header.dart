import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Shared auth header.
class AuthHeader extends StatelessWidget {
  /// Creates the auth header.
  const AuthHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// Title text.
  final String title;

  /// Subtitle text.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.headline),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(subtitle, style: AppTextStyles.bodyMuted),
      ],
    );
  }
}

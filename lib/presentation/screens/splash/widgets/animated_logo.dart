import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated logo used on the splash screen.
class AnimatedLogo extends StatelessWidget {
  /// Creates an animated logo widget.
  const AnimatedLogo({
    required this.animation,
    super.key,
  });

  /// Shared animation for fade and scale.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: SvgPicture.asset(
            AppConstants.logoAsset,
            width: AppDimensions.splashLogoSize,
            height: AppDimensions.splashLogoSize,
          ),
        ),
      ),
    );
  }
}

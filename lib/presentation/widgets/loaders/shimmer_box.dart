import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer placeholder box.
class ShimmerBox extends StatelessWidget {
  /// Creates a shimmer box.
  const ShimmerBox({
    required this.height,
    this.width = double.infinity,
    this.radius = AppDimensions.radiusLG,
    super.key,
  });

  /// Placeholder height.
  final double height;

  /// Placeholder width.
  final double width;

  /// Border radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}

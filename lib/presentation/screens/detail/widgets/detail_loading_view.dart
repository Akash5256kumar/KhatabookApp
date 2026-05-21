import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/presentation/widgets/loaders/shimmer_box.dart';
import 'package:flutter/material.dart';

/// Detail loading skeleton.
class DetailLoadingView extends StatelessWidget {
  /// Creates the loading view.
  const DetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: const <Widget>[
        ShimmerBox(height: AppDimensions.detailHeroHeight),
        SizedBox(height: AppDimensions.spaceXL),
        ShimmerBox(height: 28, width: 180),
        SizedBox(height: AppDimensions.spaceSM),
        ShimmerBox(height: 18, width: 120),
        SizedBox(height: AppDimensions.spaceXL),
        ShimmerBox(height: 88),
        SizedBox(height: AppDimensions.spaceLG),
        ShimmerBox(height: 88),
      ],
    );
  }
}

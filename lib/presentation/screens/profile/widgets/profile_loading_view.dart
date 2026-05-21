import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/presentation/widgets/loaders/shimmer_box.dart';
import 'package:flutter/material.dart';

/// Profile loading skeleton.
class ProfileLoadingView extends StatelessWidget {
  /// Creates a loading view.
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const Column(
            children: <Widget>[
              ShimmerBox(height: 160),
              SizedBox(height: AppDimensions.spaceLG),
            ],
          );
        }
        return const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spaceMD),
          child: ShimmerBox(height: 76),
        );
      },
    );
  }
}

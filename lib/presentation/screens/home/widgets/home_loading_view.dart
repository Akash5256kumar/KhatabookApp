import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/presentation/widgets/loaders/shimmer_box.dart';
import 'package:flutter/material.dart';

/// Home loading skeleton.
class HomeLoadingView extends StatelessWidget {
  /// Creates the home loading view.
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      itemCount: 8,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: <Widget>[
              const ShimmerBox(height: 120),
              const SizedBox(height: AppDimensions.spaceLG),
              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.only(right: AppDimensions.spaceMD),
                      child: SizedBox(
                        width: 180,
                        child: ShimmerBox(height: 108),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
            ],
          );
        }

        return const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spaceMD),
          child: ShimmerBox(height: AppDimensions.transactionTileExtent),
        );
      },
    );
  }
}

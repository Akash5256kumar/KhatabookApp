import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:apna_business_app/presentation/screens/onboarding/widgets/onboarding_page_card.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Onboarding screen with three pages.
class OnboardingScreen extends StatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  static const List<({String asset, String title, String subtitle})> _pages =
      <({String asset, String title, String subtitle})>[
    (
      asset: AppConstants.onboardingOneAsset,
      title: 'Business khata ko simple rakho',
      subtitle: 'Sales, payments, aur expenses ko ek clean dashboard mein dekho.',
    ),
    (
      asset: AppConstants.onboardingTwoAsset,
      title: 'Follow-up ko kabhi mat miss karo',
      subtitle: 'Customer reminders aur due amounts ko fast actions ke saath manage karo.',
    ),
    (
      asset: AppConstants.onboardingThreeAsset,
      title: 'WhatsApp-first business flow',
      subtitle: 'Invoice, reminder, aur collection journey ko phone se hi complete karo.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (OnboardingState previous, OnboardingState current) =>
          current is OnboardingSuccess || current is OnboardingFailure,
      listener: (BuildContext context, OnboardingState state) {
        if (state is OnboardingSuccess && state.isCompleted) {
          context.go(RouteNames.login);
        }
        if (state is OnboardingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (BuildContext context, OnboardingState state) {
        final int pageIndex = state.pageIndex;
        final bool isLastPage = pageIndex == AppConstants.onboardingPageCount - 1;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding,
                vertical: AppDimensions.spaceLG,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (int index) {
                        context.read<OnboardingBloc>().add(
                              OnboardingPageChanged(index),
                            );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final page = _pages[index];
                        return OnboardingPageCard(
                          assetPath: page.asset,
                          title: page.title,
                          subtitle: page.subtitle,
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      _pages.length,
                      (int index) => AnimatedContainer(
                        duration: AppDimensions.mediumDuration,
                        margin:
                            const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXS),
                        height: AppDimensions.spaceSM,
                        width: pageIndex == index ? 28 : AppDimensions.spaceSM,
                        decoration: BoxDecoration(
                          color: pageIndex == index
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  PrimaryButton(
                    label: isLastPage ? 'Get Started' : 'Continue',
                    isLoading: state is OnboardingLoading,
                    onPressed: () {
                      if (isLastPage) {
                        context.read<OnboardingBloc>().add(
                              const OnboardingCompleted(),
                            );
                        return;
                      }
                      _pageController.nextPage(
                        duration: AppDimensions.mediumDuration,
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

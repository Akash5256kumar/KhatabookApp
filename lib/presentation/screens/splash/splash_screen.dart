import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/screens/splash/widgets/animated_logo.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Initial splash screen.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.longDuration,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _init();
  }

  void _init() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _precacheAssets();
      if (!mounted) {
        return;
      }
      context.read<AuthBloc>().add(const AuthBootstrapRequested());
    });
  }

  Future<void> _precacheAssets() async {
    await Future.wait(<Future<void>>[
      const SvgAssetLoader(AppConstants.logoAsset).loadBytes(context),
      const SvgAssetLoader(AppConstants.onboardingOneAsset).loadBytes(context),
      const SvgAssetLoader(AppConstants.onboardingTwoAsset).loadBytes(context),
      const SvgAssetLoader(AppConstants.onboardingThreeAsset).loadBytes(context),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is AuthSuccess,
      listener: (BuildContext context, AuthState state) {
        if (state is! AuthSuccess) {
          return;
        }
        switch (state.session.status) {
          case AuthStatus.onboarding:
            context.go(RouteNames.onboarding);
          case AuthStatus.authenticated:
            context.go(RouteNames.home);
          case AuthStatus.unauthenticated:
            context.go(RouteNames.login);
          case AuthStatus.needsBusinessSetup:
            context.go(
              RouteNames.businessSetup,
              extra: state.session.user?.id ?? '',
            );
        }
      },
      builder: (BuildContext context, AuthState state) {
        if (state is AuthFailure) {
          return Scaffold(
            body: BrandedErrorView(
              message: state.message,
              onRetry: () {
                context.read<AuthBloc>().add(const AuthBootstrapRequested());
              },
            ),
          );
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedLogo(animation: _animation),
                  const SizedBox(height: AppDimensions.spaceXL),
                  const Text('Apna Business', style: AppTextStyles.headline),
                  const SizedBox(height: AppDimensions.spaceSM),
                  const Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
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

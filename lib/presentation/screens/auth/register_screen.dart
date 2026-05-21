import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Registration is now handled via phone OTP flow.
/// This screen redirects to [LoginScreen].
class RegisterScreen extends StatelessWidget {
  /// Creates the register screen.
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately replace with the phone login screen.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.go(RouteNames.login),
    );
    return const Scaffold(body: SizedBox.shrink());
  }
}

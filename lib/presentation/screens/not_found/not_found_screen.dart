import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fallback screen for unknown routes.
class NotFoundScreen extends StatelessWidget {
  /// Creates the not-found screen.
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Expanded(
            child: EmptyStateView(
              title: 'Page not found',
              message: 'The route is unavailable, so we sent you to a safe fallback.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              label: 'Go Home',
              onPressed: () => context.go(RouteNames.home),
            ),
          ),
        ],
      ),
    );
  }
}

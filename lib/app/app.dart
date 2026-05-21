import 'package:apna_business_app/app/routes/app_router.dart';
import 'package:apna_business_app/app/themes/app_theme.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/injection/injection_container.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root application widget.
class App extends StatelessWidget {
  /// Creates the application root.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<ThemeBloc>.value(
          value: getIt<ThemeBloc>()..add(const ThemeStarted()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (ThemeState previous, ThemeState current) =>
            previous.themeMode != current.themeMode,
        builder: (BuildContext context, ThemeState state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

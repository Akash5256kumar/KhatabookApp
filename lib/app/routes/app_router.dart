import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/injection/injection_container.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/blocs/customer/customer_detail_bloc.dart';
import 'package:apna_business_app/presentation/blocs/detail/detail_bloc.dart';
import 'package:apna_business_app/presentation/blocs/home/business_assistant_bloc.dart';
import 'package:apna_business_app/presentation/blocs/home/home_bloc.dart';
import 'package:apna_business_app/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:apna_business_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:apna_business_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:apna_business_app/presentation/blocs/transaction/payment_reminder_cubit.dart';
import 'package:apna_business_app/presentation/blocs/inventory/inventory_bloc.dart';
import 'package:apna_business_app/presentation/blocs/transaction/reminders_bloc.dart';
import 'package:apna_business_app/presentation/screens/auth/business_setup_screen.dart';
import 'package:apna_business_app/presentation/screens/auth/login_screen.dart';
import 'package:apna_business_app/presentation/screens/auth/otp_verify_screen.dart';
import 'package:apna_business_app/presentation/screens/customer_detail/customer_detail_screen.dart';
import 'package:apna_business_app/presentation/screens/detail/detail_screen.dart';
import 'package:apna_business_app/presentation/screens/home/business_assistant_screen.dart';
import 'package:apna_business_app/presentation/screens/home/home_screen.dart';
import 'package:apna_business_app/presentation/screens/invoice/invoice_screen.dart';
import 'package:apna_business_app/presentation/screens/not_found/not_found_screen.dart';
import 'package:apna_business_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:apna_business_app/presentation/screens/profile/profile_screen.dart';
import 'package:apna_business_app/presentation/screens/payment_reminder/payment_reminder_screen.dart';
import 'package:apna_business_app/presentation/screens/reminders/reminders_screen.dart';
import 'package:apna_business_app/presentation/screens/inventory/inventory_screen.dart';
import 'package:apna_business_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Application-level GoRouter configuration.
abstract final class AppRouter {
  /// Shared router instance used by [MaterialApp.router].
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const NotFoundScreen(),
    routes: <RouteBase>[
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (_, __) => BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>(),
          child: const SplashScreen(),
        ),
      ),

      // ── Onboarding ──────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (_, __) => BlocProvider<OnboardingBloc>(
          create: (_) => getIt<OnboardingBloc>(),
          child: const OnboardingScreen(),
        ),
      ),

      // ── Auth flow ────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.otpVerify,
        name: 'otpVerify',
        builder: (BuildContext context, GoRouterState state) {
          final String phone =
              state.extra is String ? state.extra! as String : '';
          return BlocProvider<AuthBloc>.value(
            value: getIt<AuthBloc>(),
            child: OtpVerifyScreen(phone: phone),
          );
        },
      ),
      GoRoute(
        path: RouteNames.businessSetup,
        name: 'businessSetup',
        builder: (BuildContext context, GoRouterState state) {
          final String phone =
              state.extra is String ? state.extra! as String : '';
          return BlocProvider<AuthBloc>.value(
            value: getIt<AuthBloc>(),
            child: BusinessSetupScreen(phone: phone),
          );
        },
      ),

      // ── Customer detail ──────────────────────────────────────────────────
      GoRoute(
        path: '${RouteNames.customerDetail}/:id',
        name: 'customerDetail',
        builder: (BuildContext context, GoRouterState state) {
          final CustomerEntity? customer =
              state.extra is CustomerEntity ? state.extra! as CustomerEntity : null;
          if (customer == null) return const NotFoundScreen();
          return BlocProvider<CustomerDetailBloc>(
            create: (_) => getIt<CustomerDetailBloc>(),
            child: CustomerDetailScreen(customer: customer),
          );
        },
      ),

      // ── Main app ─────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (_, __) => BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (_, __) => BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileStarted()),
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '${RouteNames.detail}/:id',
        name: 'detail',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          if (id.isEmpty) return const NotFoundScreen();
          final String heroTag =
              state.extra is String ? state.extra! as String : 'detail-$id';
          return BlocProvider<DetailBloc>(
            create: (_) => getIt<DetailBloc>()..add(DetailStarted(id: id)),
            child: DetailScreen(itemId: id, heroTag: heroTag),
          );
        },
      ),

      // ── Invoice ───────────────────────────────────────────────────────────
      GoRoute(
        path: '${RouteNames.invoice}/:id',
        name: 'invoice',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          if (id.isEmpty) return const NotFoundScreen();
          return BlocProvider<InvoiceBloc>(
            create: (_) => getIt<InvoiceBloc>()..add(InvoiceStarted(id: id)),
            child: InvoiceScreen(invoiceId: id),
          );
        },
      ),

      // ── Payment Reminder ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.paymentReminder,
        name: 'paymentReminder',
        builder: (BuildContext context, GoRouterState state) {
          final CustomerEntity? customer = state.extra is CustomerEntity
              ? state.extra! as CustomerEntity
              : null;
          if (customer == null) return const NotFoundScreen();
          return BlocProvider<PaymentReminderCubit>(
            create: (_) => getIt<PaymentReminderCubit>(),
            child: PaymentReminderScreen(customer: customer),
          );
        },
      ),

      // ── Reminders ─────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.reminders,
        name: 'reminders',
        builder: (_, __) => BlocProvider<RemindersBloc>(
          create: (_) => getIt<RemindersBloc>()..add(const RemindersStarted()),
          child: const RemindersScreen(),
        ),
      ),

      // ── Business Assistant ────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.businessAssistant,
        name: 'businessAssistant',
        builder: (_, __) => BlocProvider<BusinessAssistantBloc>(
          create: (_) => getIt<BusinessAssistantBloc>(),
          child: const BusinessAssistantScreen(),
        ),
      ),

      // ── Inventory ────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.inventory,
        name: 'inventory',
        builder: (_, __) => BlocProvider<InventoryBloc>(
          create: (_) => getIt<InventoryBloc>()..add(const InventoryStarted()),
          child: const InventoryScreen(),
        ),
      ),

      // ── 404 ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.notFound,
        name: 'notFound',
        builder: (_, __) => const NotFoundScreen(),
      ),
    ],
  );
}

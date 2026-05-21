import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/datasources/remote/inventory_remote_datasource.dart';
import 'package:apna_business_app/data/repositories/inventory_repository_impl.dart';
import 'package:apna_business_app/domain/repositories/inventory_repository.dart';
import 'package:apna_business_app/domain/usecases/inventory_usecases.dart';
import 'package:apna_business_app/presentation/blocs/inventory/inventory_bloc.dart';
import 'package:apna_business_app/core/storage/local_storage.dart';
import 'package:apna_business_app/data/datasources/local/app_local_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/chat_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/transcription_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/detail_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/home_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/reminder_remote_datasource.dart';
import 'package:apna_business_app/data/repositories/auth_repository_impl.dart';
import 'package:apna_business_app/data/repositories/chat_repository_impl.dart';
import 'package:apna_business_app/data/repositories/detail_repository_impl.dart';
import 'package:apna_business_app/data/repositories/home_repository_impl.dart';
import 'package:apna_business_app/data/repositories/preferences_repository_impl.dart';
import 'package:apna_business_app/data/repositories/reminder_repository_impl.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:apna_business_app/domain/repositories/detail_repository.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:apna_business_app/domain/repositories/reminder_repository.dart';
import 'package:apna_business_app/domain/usecases/check_auth_status_usecase.dart';
import 'package:apna_business_app/domain/usecases/complete_onboarding_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_customer_transactions_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_customers_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_detail_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_profile_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_reminders_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_transactions_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/logout_usecase.dart';
import 'package:apna_business_app/domain/usecases/confirm_customer_usecase.dart';
import 'package:apna_business_app/domain/usecases/confirm_transaction_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_reminder_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_message_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_otp_usecase.dart';
import 'package:apna_business_app/domain/usecases/setup_business_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_reminder_settings_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/verify_otp_usecase.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/blocs/customer/customer_detail_bloc.dart';
import 'package:apna_business_app/presentation/blocs/detail/detail_bloc.dart';
import 'package:apna_business_app/presentation/blocs/home/business_assistant_bloc.dart';
import 'package:apna_business_app/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:apna_business_app/presentation/blocs/transaction/payment_reminder_cubit.dart';
import 'package:apna_business_app/presentation/blocs/transaction/reminders_bloc.dart';
import 'package:apna_business_app/presentation/blocs/home/home_bloc.dart';
import 'package:apna_business_app/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:apna_business_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:apna_business_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers all application dependencies into [getIt].
Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthBloc>()) return;

  await Hive.initFlutter();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  getIt
    // ── Infrastructure ───────────────────────────────────────────────────
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton<LocalStorage>(() => LocalStorage(getIt()))
    ..registerLazySingleton<DioClient>(() => DioClient(getIt()))

    // ── Data sources ──────────────────────────────────────────────────────
    ..registerLazySingleton<AppLocalDataSource>(
        () => AppLocalDataSource(getIt()))
    ..registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(getIt()))
    ..registerLazySingleton<TranscriptionRemoteDataSource>(
        () => TranscriptionRemoteDataSource(getIt()))
    ..registerLazySingleton<ChatRemoteDataSource>(
        () => ChatRemoteDataSource(getIt(), getIt()))
    ..registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton<DetailRemoteDataSource>(
        () => DetailRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton<ReminderRemoteDataSource>(
        () => ReminderRemoteDataSource(getIt<DioClient>()))
    ..registerLazySingleton<InventoryRemoteDataSource>(
        () => InventoryRemoteDataSource(getIt<DioClient>()))

    // ── Repositories ──────────────────────────────────────────────────────
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl(getIt<ChatRemoteDataSource>()))
    ..registerLazySingleton<PreferencesRepository>(
        () => PreferencesRepositoryImpl(getIt()))
    ..registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(getIt()))
    ..registerLazySingleton<DetailRepository>(
        () => DetailRepositoryImpl(getIt()))
    ..registerLazySingleton<ReminderRepository>(
        () => ReminderRepositoryImpl(getIt()))
    ..registerLazySingleton<InventoryRepository>(
        () => InventoryRepositoryImpl(getIt()))

    // ── Use cases ─────────────────────────────────────────────────────────
    ..registerLazySingleton<CheckAuthStatusUseCase>(
      () => CheckAuthStatusUseCase(
        authRepository: getIt(),
        preferencesRepository: getIt(),
      ),
    )
    ..registerLazySingleton<SendMessageUseCase>(
        () => SendMessageUseCase(getIt()))
    ..registerLazySingleton<ConfirmCustomerUseCase>(
        () => ConfirmCustomerUseCase(getIt()))
    ..registerLazySingleton<ConfirmTransactionUseCase>(
        () => ConfirmTransactionUseCase(getIt()))
    ..registerLazySingleton<SendOtpUseCase>(
        () => SendOtpUseCase(getIt()))
    ..registerLazySingleton<VerifyOtpUseCase>(
        () => VerifyOtpUseCase(getIt()))
    ..registerLazySingleton<SetupBusinessUseCase>(
        () => SetupBusinessUseCase(getIt()))
    ..registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(getIt()))
    ..registerLazySingleton<CompleteOnboardingUseCase>(
        () => CompleteOnboardingUseCase(getIt()))
    ..registerLazySingleton<GetThemeModeUseCase>(
        () => GetThemeModeUseCase(getIt()))
    ..registerLazySingleton<UpdateThemeModeUseCase>(
        () => UpdateThemeModeUseCase(getIt()))
    ..registerLazySingleton<GetLanguageUseCase>(
        () => GetLanguageUseCase(getIt()))
    ..registerLazySingleton<UpdateLanguageUseCase>(
        () => UpdateLanguageUseCase(getIt()))
    ..registerLazySingleton<FetchDashboardUseCase>(
        () => FetchDashboardUseCase(getIt()))
    ..registerLazySingleton<FetchTransactionsUseCase>(
        () => FetchTransactionsUseCase(getIt()))
    ..registerLazySingleton<FetchCustomersUseCase>(
        () => FetchCustomersUseCase(getIt()))
    ..registerLazySingleton<FetchCustomerTransactionsUseCase>(
        () => FetchCustomerTransactionsUseCase(getIt()))
    ..registerLazySingleton<FetchProfileUseCase>(
        () => FetchProfileUseCase(getIt()))
    ..registerLazySingleton<FetchDetailUseCase>(
        () => FetchDetailUseCase(getIt()))
    ..registerLazySingleton<FetchRemindersUseCase>(
        () => FetchRemindersUseCase(getIt()))
    ..registerLazySingleton<UpdateReminderSettingsUseCase>(
        () => UpdateReminderSettingsUseCase(getIt()))
    ..registerLazySingleton<SendReminderUseCase>(
        () => SendReminderUseCase(getIt()))
    ..registerLazySingleton<FetchInventoryUseCase>(
        () => FetchInventoryUseCase(getIt()))
    ..registerLazySingleton<UpsertInventoryItemUseCase>(
        () => UpsertInventoryItemUseCase(getIt()))
    ..registerLazySingleton<DeleteInventoryItemUseCase>(
        () => DeleteInventoryItemUseCase(getIt()))
    ..registerLazySingleton<SearchInventoryUseCase>(
        () => SearchInventoryUseCase(getIt()))

    // ── BLoCs (singletons = global; factories = per-screen) ───────────────
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        checkAuthStatusUseCase: getIt(),
        sendOtpUseCase: getIt(),
        verifyOtpUseCase: getIt(),
        setupBusinessUseCase: getIt(),
        logoutUseCase: getIt(),
      ),
    )
    ..registerLazySingleton<ThemeBloc>(
      () => ThemeBloc(
        getThemeModeUseCase: getIt(),
        updateThemeModeUseCase: getIt(),
      ),
    )
    ..registerFactory<OnboardingBloc>(
        () => OnboardingBloc(completeOnboardingUseCase: getIt()))
    ..registerFactory<HomeBloc>(
      () => HomeBloc(
        fetchDashboardUseCase: getIt(),
        fetchTransactionsUseCase: getIt(),
        fetchCustomersUseCase: getIt(),
      ),
    )
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(
        fetchProfileUseCase: getIt(),
        getLanguageUseCase: getIt(),
        updateLanguageUseCase: getIt(),
      ),
    )
    ..registerFactory<DetailBloc>(
        () => DetailBloc(fetchDetailUseCase: getIt()))
    ..registerFactory<CustomerDetailBloc>(
      () => CustomerDetailBloc(
        fetchCustomerTransactionsUseCase: getIt(),
      ),
    )
    ..registerFactory<InvoiceBloc>(
        () => InvoiceBloc(detailDataSource: getIt<DetailRemoteDataSource>()))
    ..registerFactory<RemindersBloc>(
      () => RemindersBloc(
        fetchRemindersUseCase: getIt(),
        updateReminderSettingsUseCase: getIt(),
        sendReminderUseCase: getIt(),
      ),
    )
    ..registerFactory<PaymentReminderCubit>(
      () => PaymentReminderCubit(
        sendReminderUseCase: getIt(),
      ),
    )
    ..registerFactory<BusinessAssistantBloc>(
        () => BusinessAssistantBloc(
              sendMessageUseCase: getIt(),
              confirmCustomerUseCase: getIt(),
              confirmTransactionUseCase: getIt(),
            ))
    ..registerFactory<InventoryBloc>(
      () => InventoryBloc(
        fetchInventoryUseCase: getIt(),
        upsertInventoryItemUseCase: getIt(),
        deleteInventoryItemUseCase: getIt(),
      ),
    );
}

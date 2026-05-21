import 'package:apna_business_app/data/datasources/local/app_local_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/detail_remote_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/home_remote_datasource.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:apna_business_app/domain/repositories/detail_repository.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:apna_business_app/domain/usecases/check_auth_status_usecase.dart';
import 'package:apna_business_app/domain/usecases/complete_onboarding_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_customers_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_detail_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_profile_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_transactions_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/get_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/logout_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_otp_usecase.dart';
import 'package:apna_business_app/domain/usecases/setup_business_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_language_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_theme_mode_usecase.dart';
import 'package:apna_business_app/domain/usecases/verify_otp_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockPreferencesRepository extends Mock implements PreferencesRepository {}
class MockHomeRepository extends Mock implements HomeRepository {}
class MockDetailRepository extends Mock implements DetailRepository {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockSendOtpUseCase extends Mock implements SendOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockSetupBusinessUseCase extends Mock implements SetupBusinessUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCompleteOnboardingUseCase extends Mock implements CompleteOnboardingUseCase {}
class MockGetThemeModeUseCase extends Mock implements GetThemeModeUseCase {}
class MockUpdateThemeModeUseCase extends Mock implements UpdateThemeModeUseCase {}
class MockFetchDashboardUseCase extends Mock implements FetchDashboardUseCase {}
class MockFetchTransactionsUseCase extends Mock implements FetchTransactionsUseCase {}
class MockFetchCustomersUseCase extends Mock implements FetchCustomersUseCase {}
class MockFetchProfileUseCase extends Mock implements FetchProfileUseCase {}
class MockFetchDetailUseCase extends Mock implements FetchDetailUseCase {}
class MockGetLanguageUseCase extends Mock implements GetLanguageUseCase {}
class MockUpdateLanguageUseCase extends Mock implements UpdateLanguageUseCase {}
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}
class MockDetailRemoteDataSource extends Mock implements DetailRemoteDataSource {}
class MockAppLocalDataSource extends Mock implements AppLocalDataSource {}

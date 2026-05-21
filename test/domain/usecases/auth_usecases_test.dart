import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/domain/usecases/check_auth_status_usecase.dart';
import 'package:apna_business_app/domain/usecases/logout_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_otp_usecase.dart';
import 'package:apna_business_app/domain/usecases/setup_business_usecase.dart';
import 'package:apna_business_app/domain/usecases/verify_otp_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockPreferencesRepository prefsRepo;

  const UserEntity user =
      UserEntity(id: '1', name: 'Sharma Ji', email: 'demo@example.com');
  const AuthSessionEntity authenticated =
      AuthSessionEntity(status: AuthStatus.authenticated, user: user);
  const AuthSessionEntity needsSetup =
      AuthSessionEntity(status: AuthStatus.needsBusinessSetup);

  setUp(() {
    authRepo = MockAuthRepository();
    prefsRepo = MockPreferencesRepository();
  });

  // ── CheckAuthStatusUseCase ───────────────────────────────────────────────

  group('CheckAuthStatusUseCase', () {
    CheckAuthStatusUseCase build() => CheckAuthStatusUseCase(
          authRepository: authRepo,
          preferencesRepository: prefsRepo,
        );

    test('happy path returns authenticated session', () async {
      when(() => prefsRepo.isOnboardingSeen())
          .thenAnswer((_) async => const Right(true));
      when(() => authRepo.getCurrentSession())
          .thenAnswer((_) async => const Right(authenticated));

      expect(await build()(), const Right(authenticated));
    });

    test('network failure returns NetworkFailure', () async {
      when(() => prefsRepo.isOnboardingSeen())
          .thenAnswer((_) async => const Right(true));
      when(() => authRepo.getCurrentSession())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      expect(await build()(), const Left(NetworkFailure()));
    });

    test('empty state — onboarding not seen returns onboarding session', () async {
      when(() => prefsRepo.isOnboardingSeen())
          .thenAnswer((_) async => const Right(false));

      expect(
        await build()(),
        const Right(AuthSessionEntity(status: AuthStatus.onboarding)),
      );
    });

    test('loading transition — async call completes after await', () async {
      when(() => prefsRepo.isOnboardingSeen())
          .thenAnswer((_) async => const Right(true));
      when(() => authRepo.getCurrentSession())
          .thenAnswer((_) async => const Right(authenticated));

      final future = build()();
      expect(future, isA<Future>());
      expect(await future, const Right(authenticated));
    });
  });

  // ── SendOtpUseCase ───────────────────────────────────────────────────────

  group('SendOtpUseCase', () {
    test('happy path returns unit', () async {
      when(() => authRepo.sendOtp(phone: any(named: 'phone')))
          .thenAnswer((_) async => right(unit));

      expect(
        await SendOtpUseCase(authRepo)(phone: '9876543210'),
        right(unit),
      );
    });

    test('network failure returns NetworkFailure', () async {
      when(() => authRepo.sendOtp(phone: any(named: 'phone')))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      expect(
        await SendOtpUseCase(authRepo)(phone: '9876543210'),
        const Left(NetworkFailure()),
      );
    });

    test('empty response — rate limit returns RateLimitFailure', () async {
      when(() => authRepo.sendOtp(phone: any(named: 'phone')))
          .thenAnswer((_) async => const Left(RateLimitFailure()));

      expect(
        await SendOtpUseCase(authRepo)(phone: '9876543210'),
        const Left(RateLimitFailure()),
      );
    });
  });

  // ── VerifyOtpUseCase ─────────────────────────────────────────────────────

  group('VerifyOtpUseCase', () {
    test('happy path returning user emits authenticated', () async {
      when(() => authRepo.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const Right(authenticated));

      expect(
        await VerifyOtpUseCase(authRepo)(phone: '9876543210', otp: '123456'),
        const Right(authenticated),
      );
    });

    test('new user emits needsBusinessSetup', () async {
      when(() => authRepo.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const Right(needsSetup));

      expect(
        await VerifyOtpUseCase(authRepo)(phone: '9876543210', otp: '123456'),
        const Right(needsSetup),
      );
    });

    test('invalid OTP returns UnauthorizedFailure', () async {
      when(() => authRepo.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const Left(UnauthorizedFailure()));

      expect(
        await VerifyOtpUseCase(authRepo)(phone: '9876543210', otp: '000000'),
        const Left(UnauthorizedFailure()),
      );
    });
  });

  // ── SetupBusinessUseCase ─────────────────────────────────────────────────

  group('SetupBusinessUseCase', () {
    test('happy path returns authenticated session', () async {
      when(() => authRepo.setupBusiness(
            fullName: any(named: 'fullName'),
            businessName: any(named: 'businessName'),
          )).thenAnswer((_) async => const Right(authenticated));

      expect(
        await SetupBusinessUseCase(authRepo)(
          fullName: 'Akash Kumar',
          businessName: 'Sharma Stores',
        ),
        const Right(authenticated),
      );
    });

    test('network failure returns NetworkFailure', () async {
      when(() => authRepo.setupBusiness(
            fullName: any(named: 'fullName'),
            businessName: any(named: 'businessName'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      expect(
        await SetupBusinessUseCase(authRepo)(
          fullName: 'Akash Kumar',
          businessName: 'Sharma Stores',
        ),
        const Left(NetworkFailure()),
      );
    });
  });

  // ── LogoutUseCase ────────────────────────────────────────────────────────

  group('LogoutUseCase', () {
    test('happy path returns unit', () async {
      when(() => authRepo.logout()).thenAnswer((_) async => right(unit));
      expect(await LogoutUseCase(authRepo)(), right(unit));
    });

    test('loading transition — is asynchronous', () async {
      when(() => authRepo.logout()).thenAnswer((_) async => right(unit));
      final future = LogoutUseCase(authRepo)();
      expect(future, isA<Future>());
      expect(await future, right(unit));
    });
  });
}

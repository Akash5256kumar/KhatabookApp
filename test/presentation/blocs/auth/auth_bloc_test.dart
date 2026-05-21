import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockCheckAuthStatusUseCase checkAuthStatus;
  late MockSendOtpUseCase sendOtp;
  late MockVerifyOtpUseCase verifyOtp;
  late MockSetupBusinessUseCase setupBusiness;
  late MockLogoutUseCase logout;

  const AuthSessionEntity authenticatedSession = AuthSessionEntity(
    status: AuthStatus.authenticated,
    user: UserEntity(id: '1', name: 'Sharma Ji', email: 'a@b.com'),
  );

  setUp(() {
    checkAuthStatus = MockCheckAuthStatusUseCase();
    sendOtp = MockSendOtpUseCase();
    verifyOtp = MockVerifyOtpUseCase();
    setupBusiness = MockSetupBusinessUseCase();
    logout = MockLogoutUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        checkAuthStatusUseCase: checkAuthStatus,
        sendOtpUseCase: sendOtp,
        verifyOtpUseCase: verifyOtp,
        setupBusinessUseCase: setupBusiness,
        logoutUseCase: logout,
      );

  group('AuthBloc — bootstrap', () {
    blocTest<AuthBloc, AuthState>(
      'happy path emits loading → success',
      build: () {
        when(() => checkAuthStatus())
            .thenAnswer((_) async => const Right(authenticatedSession));
        return buildBloc();
      },
      act: (AuthBloc bloc) => bloc.add(const AuthBootstrapRequested()),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthSuccess(authenticatedSession),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'network failure emits loading → failure',
      build: () {
        when(() => checkAuthStatus())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc();
      },
      act: (AuthBloc bloc) => bloc.add(const AuthBootstrapRequested()),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthFailure(
          'Internet connection unavailable. Please try again.',
        ),
      ],
    );
  });

  group('AuthBloc — send OTP', () {
    blocTest<AuthBloc, AuthState>(
      'happy path emits loading → AuthOtpSent',
      build: () {
        when(() => sendOtp(phone: any(named: 'phone')))
            .thenAnswer((_) async => right(unit));
        return buildBloc();
      },
      act: (AuthBloc bloc) =>
          bloc.add(const AuthSendOtpRequested(phone: '9876543210')),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthOtpSent(phone: '9876543210'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'invalid phone emits AuthValidationError — no network call',
      build: buildBloc,
      act: (AuthBloc bloc) =>
          bloc.add(const AuthSendOtpRequested(phone: '123')),
      expect: () => <AuthState>[
        const AuthValidationError('Enter a valid 10-digit mobile number'),
      ],
      verify: (_) => verifyNever(() => sendOtp(phone: any(named: 'phone'))),
    );
  });

  group('AuthBloc — verify OTP', () {
    blocTest<AuthBloc, AuthState>(
      'happy path — returning user emits loading → success',
      build: () {
        when(() => verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => const Right(authenticatedSession));
        return buildBloc();
      },
      act: (AuthBloc bloc) => bloc.add(
        const AuthVerifyOtpRequested(phone: '9876543210', otp: '123456'),
      ),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthSuccess(authenticatedSession),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'new user emits loading → AuthNeedsBusinessSetup',
      build: () {
        when(() => verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenAnswer(
          (_) async => const Right(
            AuthSessionEntity(status: AuthStatus.needsBusinessSetup),
          ),
        );
        return buildBloc();
      },
      act: (AuthBloc bloc) => bloc.add(
        const AuthVerifyOtpRequested(phone: '9876543210', otp: '123456'),
      ),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthNeedsBusinessSetup(phone: '9876543210'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'short OTP emits validation error',
      build: buildBloc,
      act: (AuthBloc bloc) => bloc.add(
        const AuthVerifyOtpRequested(phone: '9876543210', otp: '12'),
      ),
      expect: () => <AuthState>[
        const AuthValidationError('Enter the 6-digit OTP'),
      ],
    );
  });

  group('AuthBloc — logout', () {
    blocTest<AuthBloc, AuthState>(
      'loading state transition then unauthenticated success',
      build: () {
        when(() => logout()).thenAnswer((_) async => right(unit));
        return buildBloc();
      },
      act: (AuthBloc bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => <AuthState>[
        const AuthLoading(),
        const AuthSuccess(
          AuthSessionEntity(status: AuthStatus.unauthenticated),
        ),
      ],
    );
  });
}

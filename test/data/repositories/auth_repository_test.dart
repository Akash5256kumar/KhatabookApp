import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/models/otp_send_response_model.dart';
import 'package:apna_business_app/data/models/otp_verify_response_model.dart';
import 'package:apna_business_app/data/models/user_model.dart';
import 'package:apna_business_app/data/repositories/auth_repository_impl.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAppLocalDataSource localDataSource;
  late AuthRepositoryImpl repository;

  const UserModel user = UserModel(id: '1', name: 'Sharma Ji', email: 'a@b.com');

  setUpAll(() {
    registerFallbackValue(const UserModel(id: '', name: '', email: ''));
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAppLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  // ── getCurrentSession ────────────────────────────────────────────────────

  group('getCurrentSession', () {
    test('has session returns authenticated', () async {
      when(() => localDataSource.hasSession()).thenReturn(true);
      when(() => localDataSource.getCurrentUser()).thenReturn(user);

      final result = await repository.getCurrentSession();
      expect(
        result.fold((_) => null, (s) => s.status),
        AuthStatus.authenticated,
      );
    });

    test('no session returns unauthenticated', () async {
      when(() => localDataSource.hasSession()).thenReturn(false);
      when(() => localDataSource.getCurrentUser()).thenReturn(null);

      expect(
        await repository.getCurrentSession(),
        const Right(AuthSessionEntity(status: AuthStatus.unauthenticated)),
      );
    });
  });

  // ── sendOtp ──────────────────────────────────────────────────────────────

  group('sendOtp', () {
    test('happy path returns unit', () async {
      when(() => remoteDataSource.sendOtp(phone: any(named: 'phone')))
          .thenAnswer((_) async => const OtpSendResponseModel(
                message: 'OTP generated successfully.',
                destination: '**ring',
                expiresInSeconds: 600,
                debugOtp: '123456',
              ));

      expect(await repository.sendOtp(phone: '9876543210'), right(unit));
    });

    test('network exception maps to NetworkFailure', () async {
      when(() => remoteDataSource.sendOtp(phone: any(named: 'phone')))
          .thenThrow(const NetworkException());

      expect(
        await repository.sendOtp(phone: '9876543210'),
        const Left(NetworkFailure()),
      );
    });

    test('unauthorized exception maps to UnauthorizedFailure', () async {
      when(() => remoteDataSource.sendOtp(phone: any(named: 'phone')))
          .thenThrow(const UnauthorizedException('Invalid phone'));

      expect(
        await repository.sendOtp(phone: '123'),
        const Left(UnauthorizedFailure()),
      );
    });
  });

  // ── verifyOtp ────────────────────────────────────────────────────────────

  group('verifyOtp', () {
    void stubSaveSession() {
      when(() => localDataSource.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            user: any(named: 'user'),
          )).thenAnswer((_) async {});
    }

    test('existing user returns authenticated', () async {
      when(() => remoteDataSource.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const OtpVerifyResponseModel(
                message: 'OTP verified successfully.',
                verified: true,
                accessToken: 'tok',
                tokenType: 'bearer',
                userId: 4,
                isNewUser: false,
              ));
      stubSaveSession();

      final result = await repository.verifyOtp(
        phone: '9876543210',
        otp: '123456',
      );
      expect(
        result.fold((_) => null, (s) => s.status),
        AuthStatus.authenticated,
      );
    });

    test('new user returns needsBusinessSetup', () async {
      when(() => remoteDataSource.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => const OtpVerifyResponseModel(
                message: 'OTP verified successfully.',
                verified: true,
                accessToken: 'tok',
                tokenType: 'bearer',
                userId: 4,
                isNewUser: true,
              ));
      stubSaveSession();

      final result = await repository.verifyOtp(
        phone: '9876543210',
        otp: '123456',
      );
      expect(
        result.fold((_) => null, (s) => s.status),
        AuthStatus.needsBusinessSetup,
      );
    });

    test('unauthorized exception maps to UnauthorizedFailure', () async {
      when(() => remoteDataSource.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenThrow(const UnauthorizedException('Incorrect OTP'));

      expect(
        await repository.verifyOtp(phone: '9876543210', otp: '000000'),
        const Left(UnauthorizedFailure()),
      );
    });

    test('network exception maps to NetworkFailure', () async {
      when(() => remoteDataSource.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenThrow(const NetworkException());

      expect(
        await repository.verifyOtp(phone: '9876543210', otp: '123456'),
        const Left(NetworkFailure()),
      );
    });
  });

  // ── setupBusiness ────────────────────────────────────────────────────────

  group('setupBusiness', () {
    test('happy path returns authenticated', () async {
      when(() => localDataSource.getCurrentUser()).thenReturn(user);
      when(() => localDataSource.hasSession()).thenReturn(true);
      when(() => localDataSource.currentAccessToken).thenReturn('token_abc');
      when(() => remoteDataSource.setupProfile(
            fullName: any(named: 'fullName'),
            businessName: any(named: 'businessName'),
          )).thenAnswer((_) async => user);
      when(() => localDataSource.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            user: any(named: 'user'),
          )).thenAnswer((_) async {});

      final result = await repository.setupBusiness(
        fullName: 'Akash Kumar',
        businessName: 'Sharma Stores',
      );
      expect(
        result.fold((_) => null, (s) => s.status),
        AuthStatus.authenticated,
      );
    });

    test('network exception maps to NetworkFailure', () async {
      when(() => localDataSource.getCurrentUser()).thenReturn(user);
      when(() => localDataSource.hasSession()).thenReturn(true);
      when(() => localDataSource.currentAccessToken).thenReturn('token_abc');
      when(() => remoteDataSource.setupProfile(
            fullName: any(named: 'fullName'),
            businessName: any(named: 'businessName'),
          )).thenThrow(const NetworkException());

      expect(
        await repository.setupBusiness(
          fullName: 'Akash Kumar',
          businessName: 'Sharma Stores',
        ),
        const Left(NetworkFailure()),
      );
    });
  });

  // ── logout ───────────────────────────────────────────────────────────────

  group('logout', () {
    test('happy path returns unit', () async {
      when(() => localDataSource.clearSession()).thenAnswer((_) async {});
      expect(await repository.logout(), right(unit));
    });

    test('cache exception maps to CacheFailure', () async {
      when(() => localDataSource.clearSession())
          .thenThrow(const CacheException());
      expect(await repository.logout(), const Left(CacheFailure()));
    });
  });
}

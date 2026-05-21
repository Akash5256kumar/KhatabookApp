import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/core/services/dev_notification_service.dart';
import 'package:apna_business_app/data/datasources/local/app_local_datasource.dart';
import 'package:apna_business_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:apna_business_app/data/models/user_model.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Authentication repository implementation.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository.
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AppLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AppLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AuthSessionEntity>> getCurrentSession() async {
    try {
      final bool hasSession = _localDataSource.hasSession();
      final currentUser = _localDataSource.getCurrentUser();
      if (!hasSession || currentUser == null) {
        return const Right(
          AuthSessionEntity(status: AuthStatus.unauthenticated),
        );
      }
      return Right(
        AuthSessionEntity(
          status: AuthStatus.authenticated,
          user: currentUser.toEntity(),
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendOtp({required String phone}) async {
    try {
      final response = await _remoteDataSource.sendOtp(phone: phone);
      if (response.debugOtp != null) {
        // Fire-and-forget — notification failure must never break auth flow.
        DevNotificationService.instance
            .showOtp(otp: response.debugOtp!, phone: phone)
            .ignore();
      }
      return right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final result = await _remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
      );
      final user = UserModel(
        id: result.userId.toString(),
        name: phone,
        email: '',
        avatarUrl: null,
      );
      await _localDataSource.saveSession(
        accessToken: result.accessToken,
        refreshToken: '',
        user: user,
      );
      final AuthStatus status = result.isNewUser
          ? AuthStatus.needsBusinessSetup
          : AuthStatus.authenticated;
      return Right(
        AuthSessionEntity(status: status, user: user.toEntity()),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthSessionEntity>> setupBusiness({
    required String fullName,
    required String businessName,
    String? location,
    String shopType = 'general',
  }) async {
    try {
      final accessToken = _localDataSource.currentAccessToken ?? '';
      final updatedUser = await _remoteDataSource.setupProfile(
        fullName: fullName,
        businessName: businessName,
        location: location,
        shopType: shopType,
      );
      await _localDataSource.saveSession(
        accessToken: accessToken,
        refreshToken: '',
        user: updatedUser,
      );
      return Right(
        AuthSessionEntity(
          status: AuthStatus.authenticated,
          user: updatedUser.toEntity(),
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _localDataSource.clearSession();
      return right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

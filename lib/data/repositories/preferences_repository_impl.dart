import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/local/app_local_datasource.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Preferences repository implementation.
class PreferencesRepositoryImpl implements PreferencesRepository {
  /// Creates the repository.
  PreferencesRepositoryImpl(this._localDataSource);

  final AppLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, bool>> isOnboardingSeen() async {
    try {
      return Right(_localDataSource.isOnboardingSeen());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setOnboardingSeen() async {
    try {
      await _localDataSource.setOnboardingSeen();
      return right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ThemeMode>> getThemeMode() async {
    try {
      final String rawMode = _localDataSource.getThemeMode();
      return Right(
        ThemeMode.values.firstWhere(
          (ThemeMode mode) => mode.name == rawMode,
          orElse: () => ThemeMode.system,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ThemeMode>> updateThemeMode(
    ThemeMode themeMode,
  ) async {
    try {
      await _localDataSource.saveThemeMode(themeMode.name);
      return Right(themeMode);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getLanguage() async {
    try {
      return Right(_localDataSource.getLanguage());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, String>> updateLanguage(String languageCode) async {
    try {
      await _localDataSource.saveLanguage(languageCode);
      return Right(languageCode);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

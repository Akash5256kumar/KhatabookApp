import 'package:apna_business_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Contract for persisted app settings and onboarding flags.
abstract interface class PreferencesRepository {
  /// Reads whether onboarding has already been completed.
  Future<Either<Failure, bool>> isOnboardingSeen();

  /// Persists onboarding completion.
  Future<Either<Failure, Unit>> setOnboardingSeen();

  /// Reads the saved [ThemeMode].
  Future<Either<Failure, ThemeMode>> getThemeMode();

  /// Persists a [ThemeMode].
  Future<Either<Failure, ThemeMode>> updateThemeMode(ThemeMode themeMode);

  /// Reads the current language code.
  Future<Either<Failure, String>> getLanguage();

  /// Persists a language code.
  Future<Either<Failure, String>> updateLanguage(String languageCode);
}

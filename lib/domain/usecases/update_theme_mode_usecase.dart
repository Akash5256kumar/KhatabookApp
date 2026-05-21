import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Persists a selected [ThemeMode].
class UpdateThemeModeUseCase {
  /// Creates the use case.
  UpdateThemeModeUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, ThemeMode>> call(ThemeMode themeMode) {
    return _repository.updateThemeMode(themeMode);
  }
}

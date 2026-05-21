import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Loads the persisted [ThemeMode].
class GetThemeModeUseCase {
  /// Creates the use case.
  GetThemeModeUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, ThemeMode>> call() => _repository.getThemeMode();
}

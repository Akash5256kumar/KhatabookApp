import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';

/// Persists onboarding completion.
class CompleteOnboardingUseCase {
  /// Creates the use case.
  CompleteOnboardingUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, Unit>> call() => _repository.setOnboardingSeen();
}

import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';

/// Persists the chosen language code.
class UpdateLanguageUseCase {
  /// Creates the use case.
  UpdateLanguageUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, String>> call(String languageCode) {
    return _repository.updateLanguage(languageCode);
  }
}

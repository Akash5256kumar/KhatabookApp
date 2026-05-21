import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads the saved language code.
class GetLanguageUseCase {
  /// Creates the use case.
  GetLanguageUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, String>> call() => _repository.getLanguage();
}

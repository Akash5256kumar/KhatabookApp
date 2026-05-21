import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:apna_business_app/domain/repositories/preferences_repository.dart';
import 'package:dartz/dartz.dart';

/// Returns the route-level auth state for the splash flow.
class CheckAuthStatusUseCase {
  /// Creates the use case.
  CheckAuthStatusUseCase({
    required AuthRepository authRepository,
    required PreferencesRepository preferencesRepository,
  })  : _authRepository = authRepository,
        _preferencesRepository = preferencesRepository;

  final AuthRepository _authRepository;
  final PreferencesRepository _preferencesRepository;

  /// Executes the use case.
  Future<Either<Failure, AuthSessionEntity>> call() async {
    final Either<Failure, bool> onboardingResult =
        await _preferencesRepository.isOnboardingSeen();
    return onboardingResult.fold(
      Left.new,
      (bool seen) async {
        if (!seen) {
          return const Right(
            AuthSessionEntity(status: AuthStatus.onboarding),
          );
        }
        return _authRepository.getCurrentSession();
      },
    );
  }
}

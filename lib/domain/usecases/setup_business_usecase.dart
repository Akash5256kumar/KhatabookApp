import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

/// Saves the business profile and transitions the session to [AuthStatus.authenticated].
class SetupBusinessUseCase {
  /// Creates the use case.
  SetupBusinessUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, AuthSessionEntity>> call({
    required String fullName,
    required String businessName,
    String? location,
    String shopType = 'general',
  }) {
    return _repository.setupBusiness(
      fullName: fullName,
      businessName: businessName,
      location: location,
      shopType: shopType,
    );
  }
}

import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Loads the home dashboard (stats, user info, recent transactions).
class FetchDashboardUseCase {
  /// Creates the use case.
  FetchDashboardUseCase(this._repository);

  final HomeRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, HomeDashboardResult>> call({required int page}) {
    return _repository.fetchDashboard(page: page);
  }
}

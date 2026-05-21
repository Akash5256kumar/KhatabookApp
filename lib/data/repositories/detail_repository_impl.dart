import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/remote/detail_remote_datasource.dart';
import 'package:apna_business_app/data/models/detail_model.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/repositories/detail_repository.dart';
import 'package:dartz/dartz.dart';

/// Detail repository implementation.
class DetailRepositoryImpl implements DetailRepository {
  /// Creates the repository.
  DetailRepositoryImpl(this._remoteDataSource);

  final DetailRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DetailEntity>> fetchDetail(String id) async {
    try {
      final response = await _remoteDataSource.fetchDetail(id);
      return Right(response.toEntity());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

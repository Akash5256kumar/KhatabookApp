import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/remote/home_remote_datasource.dart';
import 'package:apna_business_app/data/models/customer_model.dart';
import 'package:apna_business_app/data/models/home_feed_model.dart';
import 'package:apna_business_app/data/models/transaction_model.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

/// Home repository implementation.
class HomeRepositoryImpl implements HomeRepository {
  /// Creates the repository.
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, HomeDashboardResult>> fetchDashboard({
    required int page,
  }) async {
    try {
      final (feedModel, userInfo) =
          await _remoteDataSource.fetchDashboard(page: page);
      return Right((feed: feedModel.toEntity(), userInfo: userInfo));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomersPageResult>> fetchCustomers({
    required int page,
  }) async {
    try {
      final response = await _remoteDataSource.fetchCustomers(page: page);
      return Right((
        items: response.items
            .map((CustomerModel c) => c.toEntity())
            .toList(growable: false),
        page: response.page,
        hasMore: response.hasMore,
      ));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> fetchCustomerTransactions({
    required String customerId,
    required int page,
  }) async {
    try {
      final response = await _remoteDataSource.fetchCustomerTransactions(
        customerId: customerId,
        page: page,
      );
      return Right(
        response
            .map((TransactionModel t) => t.toEntity())
            .toList(growable: false),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> fetchProfile() async {
    try {
      final response = await _remoteDataSource.fetchProfile();
      return Right(response.toEntity());
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionsPageResult>> fetchTransactions({
    required int page,
  }) async {
    try {
      final response = await _remoteDataSource.fetchTransactions(page: page);
      return Right(
        (
          items: response.items
              .map((TransactionModel t) => t.toEntity())
              .toList(growable: false),
          page: response.page,
          hasMore: response.hasMore,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

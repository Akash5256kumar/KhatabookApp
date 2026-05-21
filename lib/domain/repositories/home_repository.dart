import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:apna_business_app/domain/entities/home_user_info.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

/// Combined result from the home dashboard API.
typedef HomeDashboardResult = ({HomeFeedEntity feed, HomeUserInfo userInfo});
typedef TransactionsPageResult = ({
  List<TransactionEntity> items,
  int page,
  bool hasMore,
});
typedef CustomersPageResult = ({
  List<CustomerEntity> items,
  int page,
  bool hasMore,
});

/// Contract for dashboard-related data.
abstract interface class HomeRepository {
  /// Fetches the full dashboard (stats + user info + recent transactions).
  Future<Either<Failure, HomeDashboardResult>> fetchDashboard(
      {required int page});

  /// Fetches paginated transactions.
  Future<Either<Failure, TransactionsPageResult>> fetchTransactions({
    required int page,
  });

  /// Fetches paginated customers.
  Future<Either<Failure, CustomersPageResult>> fetchCustomers({
    required int page,
  });

  /// Fetches transactions for a specific customer.
  Future<Either<Failure, List<TransactionEntity>>> fetchCustomerTransactions({
    required String customerId,
    required int page,
  });

  /// Fetches the signed-in profile.
  Future<Either<Failure, UserEntity>> fetchProfile();
}

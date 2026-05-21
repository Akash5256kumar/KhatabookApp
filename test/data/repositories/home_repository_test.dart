import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/models/customer_model.dart';
import 'package:apna_business_app/data/models/home_feed_model.dart';
import 'package:apna_business_app/data/models/transaction_model.dart';
import 'package:apna_business_app/data/models/user_model.dart';
import 'package:apna_business_app/data/repositories/home_repository_impl.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockHomeRemoteDataSource remoteDataSource;
  late HomeRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockHomeRemoteDataSource();
    repository = HomeRepositoryImpl(remoteDataSource);
  });

  group('HomeRepositoryImpl', () {
    test('happy path returns dashboard data', () async {
      when(() => remoteDataSource.fetchDashboard(page: 1)).thenAnswer(
        (_) async => HomeFeedModel(
          metrics: <SummaryMetricModel>[
            const SummaryMetricModel(title: 'Sales', amount: 10, helperText: 'Today'),
          ],
          feedItems: <TransactionModel>[
            TransactionModel(
              id: '1',
              customerName: 'Sharma Ji',
              title: 'Sale',
              subtitle: 'Bag cement',
              imageUrl: 'https://example.com',
              amount: 10,
              createdAt: DateTime(2024),
              type: TransactionType.sale,
              isPositive: true,
            ),
          ],
          page: 1,
          hasMore: true,
        ),
      );

      final result = await repository.fetchDashboard(page: 1);
      expect(result.isRight(), isTrue);
    });

    test('network failure maps to failure', () async {
      when(() => remoteDataSource.fetchTransactions(page: 1))
          .thenThrow(const NetworkException());

      expect(await repository.fetchTransactions(page: 1), left(const NetworkFailure()));
    });

    test('empty response returns empty collections', () async {
      when(() => remoteDataSource.fetchCustomers(page: 2))
          .thenAnswer((_) async => <CustomerModel>[]);

      final result = await repository.fetchCustomers(page: 2);
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => <CustomerEntity>[]), isEmpty);
    });

    test('loading state transition equivalent fetches profile asynchronously', () async {
      when(() => remoteDataSource.fetchProfile())
          .thenAnswer((_) async => const UserModel(id: '1', name: 'User', email: 'a@b.com'));

      final result = await repository.fetchProfile();
      expect(result.isRight(), isTrue);
    });
  });
}

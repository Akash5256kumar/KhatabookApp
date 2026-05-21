import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/entities/user_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_customers_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_profile_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_transactions_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_mocks.dart';

void main() {
  late MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
  });

  final HomeFeedEntity feed = HomeFeedEntity(
    metrics: <SummaryMetricEntity>[
      const SummaryMetricEntity(title: 'Sales', amount: 10, helperText: 'Today'),
    ],
    feedItems: <TransactionEntity>[
      TransactionEntity(
        id: '1',
        customerName: 'Sharma Ji',
        title: 'Sale',
        subtitle: 'Bag cement',
        imageUrl: 'https://example.com/image.jpg',
        amount: 10,
        createdAt: DateTime(2024),
        type: TransactionType.sale,
        isPositive: true,
      ),
    ],
    page: 1,
    hasMore: true,
  );

  final List<TransactionEntity> transactions = <TransactionEntity>[
    TransactionEntity(
      id: '1',
      customerName: 'Sharma Ji',
      title: 'Sale',
      subtitle: 'Bag cement',
      imageUrl: 'https://example.com/image.jpg',
      amount: 10,
      createdAt: DateTime(2024),
      type: TransactionType.sale,
      isPositive: true,
    ),
  ];

  final List<CustomerEntity> customers = <CustomerEntity>[
    CustomerEntity(
      id: '1',
      name: 'Sharma Ji',
      phone: '9999999999',
      balance: 50,
      updatedAt: DateTime(2024),
    ),
  ];

  const UserEntity user = UserEntity(id: '1', name: 'User', email: 'a@b.com');

  group('Home use cases', () {
    test('happy path returns data', () async {
      when(() => repository.fetchDashboard(page: 1))
          .thenAnswer((_) async => Right(feed));
      when(() => repository.fetchTransactions(page: 1))
          .thenAnswer((_) async => Right(transactions));
      when(() => repository.fetchCustomers(page: 1))
          .thenAnswer((_) async => Right(customers));
      when(() => repository.fetchProfile())
          .thenAnswer((_) async => const Right(user));

      expect(await FetchDashboardUseCase(repository).call(page: 1), Right(feed));
      expect(await FetchTransactionsUseCase(repository).call(page: 1), Right(transactions));
      expect(await FetchCustomersUseCase(repository).call(page: 1), Right(customers));
      expect(await FetchProfileUseCase(repository).call(), const Right(user));
    });

    test('network failure returns failure', () async {
      when(() => repository.fetchDashboard(page: 1))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      expect(
        await FetchDashboardUseCase(repository).call(page: 1),
        const Left(NetworkFailure()),
      );
    });

    test('empty response returns empty collections', () async {
      when(() => repository.fetchTransactions(page: 1))
          .thenAnswer((_) async => const Right(<TransactionEntity>[]));

      expect(
        await FetchTransactionsUseCase(repository).call(page: 1),
        const Right(<TransactionEntity>[]),
      );
    });

    test('loading transition equivalent remains future-based', () async {
      when(() => repository.fetchCustomers(page: 2))
          .thenAnswer((_) async => Right(customers));

      expect(
        await FetchCustomersUseCase(repository).call(page: 2),
        Right(customers),
      );
    });
  });
}

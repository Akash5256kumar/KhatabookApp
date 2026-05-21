import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/presentation/blocs/home/home_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_mocks.dart';

void main() {
  late MockFetchDashboardUseCase fetchDashboardUseCase;
  late MockFetchTransactionsUseCase fetchTransactionsUseCase;
  late MockFetchCustomersUseCase fetchCustomersUseCase;

  final HomeFeedEntity dashboard = HomeFeedEntity(
    metrics: <SummaryMetricEntity>[
      const SummaryMetricEntity(title: 'Sales', amount: 10, helperText: 'Today'),
    ],
    feedItems: <TransactionEntity>[
      TransactionEntity(
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
  );

  final List<TransactionEntity> transactions = <TransactionEntity>[
    TransactionEntity(
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
  ];

  final List<CustomerEntity> customers = <CustomerEntity>[
    CustomerEntity(
      id: '1',
      name: 'Sharma Ji',
      phone: '9999999999',
      balance: 20,
      updatedAt: DateTime(2024),
    ),
  ];

  setUp(() {
    fetchDashboardUseCase = MockFetchDashboardUseCase();
    fetchTransactionsUseCase = MockFetchTransactionsUseCase();
    fetchCustomersUseCase = MockFetchCustomersUseCase();
  });

  HomeBloc buildBloc() => HomeBloc(
        fetchDashboardUseCase: fetchDashboardUseCase,
        fetchTransactionsUseCase: fetchTransactionsUseCase,
        fetchCustomersUseCase: fetchCustomersUseCase,
      );

  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'happy path emits loading then success',
      build: () {
        when(() => fetchDashboardUseCase(page: 1))
            .thenAnswer((_) async => Right(dashboard));
        when(() => fetchTransactionsUseCase(page: 1))
            .thenAnswer((_) async => Right(transactions));
        when(() => fetchCustomersUseCase(page: 1))
            .thenAnswer((_) async => Right(customers));
        return buildBloc();
      },
      act: (HomeBloc bloc) => bloc.add(const HomeStarted()),
      expect: () => <HomeState>[
        const HomeLoading(tabIndex: 0),
        HomeSuccess(
          tabIndex: 0,
          dashboard: dashboard,
          transactions: transactions,
          customers: customers,
          dashboardPage: 1,
          transactionPage: 1,
          customerPage: 1,
          hasMoreDashboard: true,
          hasMoreTransactions: true,
          hasMoreCustomers: true,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'network failure emits failure',
      build: () {
        when(() => fetchDashboardUseCase(page: 1))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => fetchTransactionsUseCase(page: 1))
            .thenAnswer((_) async => Right(transactions));
        when(() => fetchCustomersUseCase(page: 1))
            .thenAnswer((_) async => Right(customers));
        return buildBloc();
      },
      act: (HomeBloc bloc) => bloc.add(const HomeStarted()),
      expect: () => <HomeState>[
        const HomeLoading(tabIndex: 0),
        const HomeFailure(
          tabIndex: 0,
          message: 'Internet connection unavailable. Please try again.',
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'empty response emits empty state',
      build: () {
        when(() => fetchDashboardUseCase(page: 1)).thenAnswer(
          (_) async => const Right(
            HomeFeedEntity(
              metrics: <SummaryMetricEntity>[],
              feedItems: <TransactionEntity>[],
              page: 1,
              hasMore: false,
            ),
          ),
        );
        when(() => fetchTransactionsUseCase(page: 1))
            .thenAnswer((_) async => const Right(<TransactionEntity>[]));
        when(() => fetchCustomersUseCase(page: 1))
            .thenAnswer((_) async => const Right(<CustomerEntity>[]));
        return buildBloc();
      },
      act: (HomeBloc bloc) => bloc.add(const HomeStarted()),
      expect: () => <HomeState>[
        const HomeLoading(tabIndex: 0),
        const HomeEmpty(tabIndex: 0),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'loading state transition appends more transactions',
      build: () {
        when(() => fetchTransactionsUseCase(page: 2)).thenAnswer(
          (_) async => Right(
            <TransactionEntity>[
              TransactionEntity(
                id: '2',
                customerName: 'Verma Ji',
                title: 'Payment',
                subtitle: 'UPI',
                imageUrl: 'https://example.com',
                amount: 20,
                createdAt: DateTime(2024),
                type: TransactionType.payment,
                isPositive: true,
              ),
            ],
          ),
        );
        return buildBloc();
      },
      seed: () => HomeSuccess(
        tabIndex: 1,
        dashboard: dashboard,
        transactions: transactions,
        customers: customers,
        dashboardPage: 1,
        transactionPage: 1,
        customerPage: 1,
        hasMoreDashboard: true,
        hasMoreTransactions: true,
        hasMoreCustomers: true,
        isLoadingMore: false,
      ),
      act: (HomeBloc bloc) => bloc.add(const HomeLoadMoreRequested()),
      expect: () => <HomeState>[
        HomeSuccess(
          tabIndex: 1,
          dashboard: dashboard,
          transactions: transactions,
          customers: customers,
          dashboardPage: 1,
          transactionPage: 1,
          customerPage: 1,
          hasMoreDashboard: true,
          hasMoreTransactions: true,
          hasMoreCustomers: true,
          isLoadingMore: true,
        ),
        HomeSuccess(
          tabIndex: 1,
          dashboard: dashboard,
          transactions: <TransactionEntity>[
            TransactionEntity(
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
            TransactionEntity(
              id: '2',
              customerName: 'Verma Ji',
              title: 'Payment',
              subtitle: 'UPI',
              imageUrl: 'https://example.com',
              amount: 20,
              createdAt: DateTime(2024),
              type: TransactionType.payment,
              isPositive: true,
            ),
          ],
          customers: customers,
          dashboardPage: 1,
          transactionPage: 2,
          customerPage: 1,
          hasMoreDashboard: true,
          hasMoreTransactions: true,
          hasMoreCustomers: true,
          isLoadingMore: false,
        ),
      ],
    );
  });
}

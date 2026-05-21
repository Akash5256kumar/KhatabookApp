import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:apna_business_app/domain/entities/home_user_info.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/repositories/home_repository.dart';
import 'package:apna_business_app/domain/usecases/fetch_customers_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_dashboard_usecase.dart';
import 'package:apna_business_app/domain/usecases/fetch_transactions_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Manages dashboard, transactions, customers, and tab state.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  /// Creates the bloc.
  HomeBloc({
    required FetchDashboardUseCase fetchDashboardUseCase,
    required FetchTransactionsUseCase fetchTransactionsUseCase,
    required FetchCustomersUseCase fetchCustomersUseCase,
  })  : _fetchDashboardUseCase = fetchDashboardUseCase,
        _fetchTransactionsUseCase = fetchTransactionsUseCase,
        _fetchCustomersUseCase = fetchCustomersUseCase,
        super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeLoadMoreRequested>(_onLoadMoreRequested);
    on<HomeTabChanged>(_onTabChanged);
  }

  final FetchDashboardUseCase _fetchDashboardUseCase;
  final FetchTransactionsUseCase _fetchTransactionsUseCase;
  final FetchCustomersUseCase _fetchCustomersUseCase;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    await _loadInitial(tabIndex: state.tabIndex, emit: emit);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _loadInitial(tabIndex: state.tabIndex, emit: emit);
  }

  void _onTabChanged(
    HomeTabChanged event,
    Emitter<HomeState> emit,
  ) {
    final HomeState current = state;
    if (current is HomeSuccess) {
      emit(current.copyWith(tabIndex: event.tabIndex));
      return;
    }
    if (current is HomeFailure) {
      emit(HomeFailure(tabIndex: event.tabIndex, message: current.message));
      return;
    }
    if (current is HomeEmpty) {
      emit(HomeEmpty(tabIndex: event.tabIndex));
      return;
    }
    emit(HomeLoading(tabIndex: event.tabIndex));
  }

  Future<void> _onLoadMoreRequested(
    HomeLoadMoreRequested event,
    Emitter<HomeState> emit,
  ) async {
    final HomeState current = state;
    if (current is! HomeSuccess || current.isLoadingMore) return;

    switch (current.tabIndex) {
      case 0:
        if (!current.hasMoreDashboard) return;
        emit(current.copyWith(isLoadingMore: true));
        final result =
            await _fetchDashboardUseCase(page: current.dashboardPage + 1);
        result.fold(
          (failure) => emit(
            HomeFailure(tabIndex: current.tabIndex, message: failure.message),
          ),
          (HomeDashboardResult data) => emit(
            current.copyWith(
              dashboard: current.dashboard.copyWith(
                metrics: data.feed.metrics,
                feedItems: <TransactionEntity>[
                  ...current.dashboard.feedItems,
                  ...data.feed.feedItems,
                ],
                page: data.feed.page,
                hasMore: data.feed.hasMore,
              ),
              dashboardPage: data.feed.page,
              hasMoreDashboard: data.feed.hasMore,
              userInfo: data.userInfo,
              isLoadingMore: false,
            ),
          ),
        );
      case 1:
        if (!current.hasMoreTransactions) return;
        emit(current.copyWith(isLoadingMore: true));
        final result = await _fetchTransactionsUseCase(
          page: current.transactionPage + 1,
        );
        result.fold(
          (failure) => emit(
            HomeFailure(tabIndex: current.tabIndex, message: failure.message),
          ),
          (transactionsPage) => emit(
            current.copyWith(
              transactions: <TransactionEntity>[
                ...current.transactions,
                ...transactionsPage.items,
              ],
              transactionPage: transactionsPage.page,
              hasMoreTransactions: transactionsPage.hasMore,
              isLoadingMore: false,
            ),
          ),
        );
      case 2:
        if (!current.hasMoreCustomers) return;
        emit(current.copyWith(isLoadingMore: true));
        final result = await _fetchCustomersUseCase(
          page: current.customerPage + 1,
        );
        result.fold(
          (failure) => emit(
            HomeFailure(tabIndex: current.tabIndex, message: failure.message),
          ),
          (CustomersPageResult customersPage) => emit(
            current.copyWith(
              customers: <CustomerEntity>[
                ...current.customers,
                ...customersPage.items,
              ],
              customerPage: customersPage.page,
              hasMoreCustomers: customersPage.hasMore,
              isLoadingMore: false,
            ),
          ),
        );
      default:
        return;
    }
  }

  Future<void> _loadInitial({
    required int tabIndex,
    required Emitter<HomeState> emit,
  }) async {
    emit(HomeLoading(tabIndex: tabIndex));
    final dashboardResult = await _fetchDashboardUseCase(page: 1);
    final transactionsResult = await _fetchTransactionsUseCase(page: 1);
    final customersResult = await _fetchCustomersUseCase(page: 1);

    dashboardResult.fold(
      (failure) =>
          emit(HomeFailure(tabIndex: tabIndex, message: failure.message)),
      (HomeDashboardResult dashData) {
        transactionsResult.fold(
          (failure) => emit(
            HomeFailure(tabIndex: tabIndex, message: failure.message),
          ),
          (transactionsPage) {
            customersResult.fold(
              (failure) => emit(
                HomeFailure(tabIndex: tabIndex, message: failure.message),
              ),
              (CustomersPageResult customersPage) {
                final bool isAllEmpty = dashData.feed.feedItems.isEmpty &&
                    transactionsPage.items.isEmpty &&
                    customersPage.items.isEmpty;
                if (isAllEmpty) {
                  emit(HomeEmpty(tabIndex: tabIndex));
                  return;
                }
                emit(
                  HomeSuccess(
                    tabIndex: tabIndex,
                    dashboard: dashData.feed,
                    transactions: transactionsPage.items,
                    customers: customersPage.items,
                    dashboardPage: 1,
                    transactionPage: transactionsPage.page,
                    customerPage: customersPage.page,
                    hasMoreDashboard: dashData.feed.hasMore,
                    hasMoreTransactions: transactionsPage.hasMore,
                    hasMoreCustomers: customersPage.hasMore,
                    isLoadingMore: false,
                    userInfo: dashData.userInfo,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

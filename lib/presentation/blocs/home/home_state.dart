part of 'home_bloc.dart';

/// Base state for [HomeBloc].
sealed class HomeState extends Equatable {
  /// Creates the state.
  const HomeState({required this.tabIndex});

  /// Selected tab index.
  final int tabIndex;

  @override
  List<Object?> get props => <Object?>[tabIndex];
}

/// Initial home state.
final class HomeInitial extends HomeState {
  /// Creates the state.
  const HomeInitial() : super(tabIndex: 0);
}

/// Loading home state.
final class HomeLoading extends HomeState {
  /// Creates the state.
  const HomeLoading({required super.tabIndex});
}

/// Success home state.
final class HomeSuccess extends HomeState {
  /// Creates the state.
  const HomeSuccess({
    required super.tabIndex,
    required this.dashboard,
    required this.transactions,
    required this.customers,
    required this.dashboardPage,
    required this.transactionPage,
    required this.customerPage,
    required this.hasMoreDashboard,
    required this.hasMoreTransactions,
    required this.hasMoreCustomers,
    required this.isLoadingMore,
    required this.userInfo,
  });

  /// Dashboard feed data.
  final HomeFeedEntity dashboard;

  /// Transaction data.
  final List<TransactionEntity> transactions;

  /// Customer data.
  final List<CustomerEntity> customers;

  /// Current dashboard page.
  final int dashboardPage;

  /// Current transaction page.
  final int transactionPage;

  /// Current customer page.
  final int customerPage;

  /// Whether dashboard has more pages.
  final bool hasMoreDashboard;

  /// Whether transactions have more pages.
  final bool hasMoreTransactions;

  /// Whether customers have more pages.
  final bool hasMoreCustomers;

  /// Whether pagination is in progress.
  final bool isLoadingMore;

  /// User, business, and top-customer info from the API.
  final HomeUserInfo userInfo;

  @override
  List<Object?> get props => <Object?>[
        tabIndex,
        dashboard,
        transactions,
        customers,
        dashboardPage,
        transactionPage,
        customerPage,
        hasMoreDashboard,
        hasMoreTransactions,
        hasMoreCustomers,
        isLoadingMore,
        userInfo,
      ];

  /// Returns a copy with changes.
  HomeSuccess copyWith({
    int? tabIndex,
    HomeFeedEntity? dashboard,
    List<TransactionEntity>? transactions,
    List<CustomerEntity>? customers,
    int? dashboardPage,
    int? transactionPage,
    int? customerPage,
    bool? hasMoreDashboard,
    bool? hasMoreTransactions,
    bool? hasMoreCustomers,
    bool? isLoadingMore,
    HomeUserInfo? userInfo,
  }) {
    return HomeSuccess(
      tabIndex: tabIndex ?? this.tabIndex,
      dashboard: dashboard ?? this.dashboard,
      transactions: transactions ?? this.transactions,
      customers: customers ?? this.customers,
      dashboardPage: dashboardPage ?? this.dashboardPage,
      transactionPage: transactionPage ?? this.transactionPage,
      customerPage: customerPage ?? this.customerPage,
      hasMoreDashboard: hasMoreDashboard ?? this.hasMoreDashboard,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}

/// Empty home state.
final class HomeEmpty extends HomeState {
  /// Creates the state.
  const HomeEmpty({required super.tabIndex});
}

/// Failure home state.
final class HomeFailure extends HomeState {
  /// Creates the state.
  const HomeFailure({
    required super.tabIndex,
    required this.message,
  });

  /// Error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[tabIndex, message];
}

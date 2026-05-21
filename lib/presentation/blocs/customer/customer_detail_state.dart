part of 'customer_detail_bloc.dart';

/// States for [CustomerDetailBloc].
sealed class CustomerDetailState extends Equatable {
  const CustomerDetailState();

  /// Active type filter; [null] = show all.
  TransactionType? get filter => null;

  @override
  List<Object?> get props => <Object?>[];
}

/// Pre-load state.
final class CustomerDetailInitial extends CustomerDetailState {
  /// Creates the state.
  const CustomerDetailInitial();
}

/// Spinner state while data loads.
final class CustomerDetailLoading extends CustomerDetailState {
  /// Creates the state.
  const CustomerDetailLoading({this.filter});

  @override
  final TransactionType? filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

/// Data available for rendering.
final class CustomerDetailSuccess extends CustomerDetailState {
  /// Creates the state.
  const CustomerDetailSuccess({
    required this.customer,
    required this.transactions,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    this.filter,
  });

  /// Customer entity shown in the header.
  final CustomerEntity customer;

  /// Full (unfiltered) transaction list for the loaded pages.
  final List<TransactionEntity> transactions;

  /// Current page index (1-based).
  final int page;

  /// Whether more pages may exist.
  final bool hasMore;

  /// True while the next page is fetching.
  final bool isLoadingMore;

  @override
  final TransactionType? filter;

  /// Transactions after the active [filter] is applied.
  List<TransactionEntity> get visibleTransactions => filter == null
      ? transactions
      : transactions
          .where((TransactionEntity t) => t.type == filter)
          .toList(growable: false);

  /// Returns a copy with the specified fields replaced.
  CustomerDetailSuccess copyWith({
    CustomerEntity? customer,
    List<TransactionEntity>? transactions,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    Object? filter = _sentinel,
  }) {
    return CustomerDetailSuccess(
      customer: customer ?? this.customer,
      transactions: transactions ?? this.transactions,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filter: filter == _sentinel ? this.filter : filter as TransactionType?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        customer,
        transactions,
        page,
        hasMore,
        isLoadingMore,
        filter,
      ];
}

/// No transactions found for this customer.
final class CustomerDetailEmpty extends CustomerDetailState {
  /// Creates the state.
  const CustomerDetailEmpty({this.customer});

  /// Customer entity (kept for header rendering).
  final CustomerEntity? customer;

  @override
  List<Object?> get props => <Object?>[customer];
}

/// Error loading data.
final class CustomerDetailFailure extends CustomerDetailState {
  /// Creates the state.
  const CustomerDetailFailure(this.message);

  /// Human-readable error message.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// Sentinel to distinguish "pass null" from "don't override".
const Object _sentinel = Object();

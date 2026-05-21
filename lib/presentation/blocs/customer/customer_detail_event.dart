part of 'customer_detail_bloc.dart';

/// Events for [CustomerDetailBloc].
sealed class CustomerDetailEvent extends Equatable {
  const CustomerDetailEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Bootstraps loading for [customer].
final class CustomerDetailStarted extends CustomerDetailEvent {
  /// Creates the event.
  const CustomerDetailStarted({required this.customer});

  /// Customer whose detail is being viewed.
  final CustomerEntity customer;

  @override
  List<Object?> get props => <Object?>[customer.id];
}

/// Refreshes from page 1.
final class CustomerDetailRefreshed extends CustomerDetailEvent {
  /// Creates the event.
  const CustomerDetailRefreshed();
}

/// Requests the next page of transactions.
final class CustomerDetailLoadMoreRequested extends CustomerDetailEvent {
  /// Creates the event.
  const CustomerDetailLoadMoreRequested();
}

/// Applies or clears a transaction type filter.
final class CustomerDetailFilterChanged extends CustomerDetailEvent {
  /// Creates the event.
  const CustomerDetailFilterChanged({this.filter});

  /// [null] means show all types.
  final TransactionType? filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

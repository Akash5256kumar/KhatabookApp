import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_customer_transactions_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_detail_event.dart';
part 'customer_detail_state.dart';

/// Manages transactions and filter state for a single customer.
class CustomerDetailBloc
    extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  /// Creates the bloc.
  CustomerDetailBloc({
    required FetchCustomerTransactionsUseCase fetchCustomerTransactionsUseCase,
  })  : _fetchUseCase = fetchCustomerTransactionsUseCase,
        super(const CustomerDetailInitial()) {
    on<CustomerDetailStarted>(_onStarted);
    on<CustomerDetailRefreshed>(_onRefreshed);
    on<CustomerDetailLoadMoreRequested>(_onLoadMore);
    on<CustomerDetailFilterChanged>(_onFilterChanged);
  }

  final FetchCustomerTransactionsUseCase _fetchUseCase;

  CustomerEntity? _customer;

  Future<void> _onStarted(
    CustomerDetailStarted event,
    Emitter<CustomerDetailState> emit,
  ) async {
    _customer = event.customer;
    await _loadPage(page: 1, emit: emit);
  }

  Future<void> _onRefreshed(
    CustomerDetailRefreshed event,
    Emitter<CustomerDetailState> emit,
  ) async {
    await _loadPage(page: 1, emit: emit);
  }

  Future<void> _onLoadMore(
    CustomerDetailLoadMoreRequested event,
    Emitter<CustomerDetailState> emit,
  ) async {
    final CustomerDetailState current = state;
    if (current is! CustomerDetailSuccess ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _fetchUseCase(
      customerId: current.customer.id,
      page: current.page + 1,
    );
    result.fold(
      (failure) => emit(CustomerDetailFailure(failure.message)),
      (newItems) => emit(
        current.copyWith(
          transactions: <TransactionEntity>[
            ...current.transactions,
            ...newItems,
          ],
          page: current.page + 1,
          hasMore: newItems.isNotEmpty,
          isLoadingMore: false,
        ),
      ),
    );
  }

  void _onFilterChanged(
    CustomerDetailFilterChanged event,
    Emitter<CustomerDetailState> emit,
  ) {
    final CustomerDetailState current = state;
    if (current is CustomerDetailSuccess) {
      emit(current.copyWith(filter: event.filter));
    }
  }

  Future<void> _loadPage({
    required int page,
    required Emitter<CustomerDetailState> emit,
  }) async {
    final CustomerEntity? customer = _customer;
    if (customer == null) return;
    emit(CustomerDetailLoading(filter: state.filter));
    final result = await _fetchUseCase(
      customerId: customer.id,
      page: page,
    );
    result.fold(
      (failure) => emit(CustomerDetailFailure(failure.message)),
      (transactions) {
        if (transactions.isEmpty) {
          emit(CustomerDetailEmpty(customer: customer));
        } else {
          emit(
            CustomerDetailSuccess(
              customer: customer,
              transactions: transactions,
              page: page,
              hasMore: transactions.isNotEmpty,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }
}

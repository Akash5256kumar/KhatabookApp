import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/domain/usecases/inventory_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

/// Manages inventory list state: load, upsert, delete.
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc({
    required FetchInventoryUseCase fetchInventoryUseCase,
    required UpsertInventoryItemUseCase upsertInventoryItemUseCase,
    required DeleteInventoryItemUseCase deleteInventoryItemUseCase,
  })  : _fetch = fetchInventoryUseCase,
        _upsert = upsertInventoryItemUseCase,
        _delete = deleteInventoryItemUseCase,
        super(const InventoryInitial()) {
    on<InventoryStarted>(_onStarted);
    on<InventoryRefreshed>(_onRefreshed);
    on<InventoryItemUpserted>(_onUpserted);
    on<InventoryItemDeleted>(_onDeleted);
  }

  final FetchInventoryUseCase _fetch;
  final UpsertInventoryItemUseCase _upsert;
  final DeleteInventoryItemUseCase _delete;

  Future<void> _onStarted(
    InventoryStarted event,
    Emitter<InventoryState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefreshed(
    InventoryRefreshed event,
    Emitter<InventoryState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<InventoryState> emit) async {
    emit(const InventoryLoading());
    final result = await _fetch();
    result.fold(
      (failure) => emit(InventoryFailure(failure.message)),
      (items) => items.isEmpty
          ? emit(const InventoryEmpty())
          : emit(InventorySuccess(items)),
    );
  }

  Future<void> _onUpserted(
    InventoryItemUpserted event,
    Emitter<InventoryState> emit,
  ) async {
    final current = _currentItems();
    emit(InventoryActionInProgress(current));
    final result = await _upsert(
      category: event.category,
      productName: event.productName,
      quantity: event.quantity,
      unit: event.unit,
      lastPurchasePrice: event.lastPurchasePrice,
      lastSalePrice: event.lastSalePrice,
    );
    result.fold(
      (failure) => emit(InventoryFailure(failure.message)),
      (_) => add(const InventoryRefreshed()),
    );
  }

  Future<void> _onDeleted(
    InventoryItemDeleted event,
    Emitter<InventoryState> emit,
  ) async {
    final current = _currentItems();
    emit(InventoryActionInProgress(current));
    final result = await _delete(event.id);
    result.fold(
      (failure) => emit(InventoryFailure(failure.message)),
      (_) => add(const InventoryRefreshed()),
    );
  }

  List<InventoryItemEntity> _currentItems() {
    final s = state;
    if (s is InventorySuccess) return s.items;
    if (s is InventoryActionInProgress) return s.items;
    return const <InventoryItemEntity>[];
  }
}

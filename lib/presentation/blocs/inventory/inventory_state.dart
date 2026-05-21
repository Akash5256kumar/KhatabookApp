part of 'inventory_bloc.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => <Object?>[];
}

final class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

final class InventorySuccess extends InventoryState {
  const InventorySuccess(this.items);

  final List<InventoryItemEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

final class InventoryEmpty extends InventoryState {
  const InventoryEmpty();
}

final class InventoryFailure extends InventoryState {
  const InventoryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

final class InventoryActionInProgress extends InventoryState {
  const InventoryActionInProgress(this.items);

  final List<InventoryItemEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

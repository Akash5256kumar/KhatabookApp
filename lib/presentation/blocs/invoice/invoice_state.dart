part of 'invoice_bloc.dart';

/// States for [InvoiceBloc].
sealed class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Pre-load state.
final class InvoiceInitial extends InvoiceState {
  /// Creates the state.
  const InvoiceInitial();
}

/// Loading spinner.
final class InvoiceLoading extends InvoiceState {
  /// Creates the state.
  const InvoiceLoading();
}

/// Invoice data available.
final class InvoiceSuccess extends InvoiceState {
  /// Creates the state.
  const InvoiceSuccess(this.invoice);

  /// Loaded invoice.
  final InvoiceEntity invoice;

  @override
  List<Object?> get props => <Object?>[invoice];
}

/// No invoice found.
final class InvoiceEmpty extends InvoiceState {
  /// Creates the state.
  const InvoiceEmpty();
}

/// Error loading invoice.
final class InvoiceFailure extends InvoiceState {
  /// Creates the state.
  const InvoiceFailure(this.message);

  /// Human-readable error.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

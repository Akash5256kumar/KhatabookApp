part of 'invoice_bloc.dart';

/// Events for [InvoiceBloc].
sealed class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the invoice identified by [id].
final class InvoiceStarted extends InvoiceEvent {
  /// Creates the event.
  const InvoiceStarted({required this.id});

  /// Invoice identifier.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Retries after a failure.
final class InvoiceRetried extends InvoiceEvent {
  /// Creates the event.
  const InvoiceRetried({required this.id});

  /// Invoice identifier.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

part of 'payment_reminder_cubit.dart';

/// Status for the reminder composer flow.
enum PaymentReminderStatus { initial, sending, success, failure }

/// State for the reminder composer.
class PaymentReminderState extends Equatable {
  /// Creates the state.
  const PaymentReminderState({
    this.status = PaymentReminderStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  /// Current request status.
  final PaymentReminderStatus status;

  /// Latest failure message.
  final String? errorMessage;

  /// Latest success message.
  final String? successMessage;

  /// Whether a request is in flight.
  bool get isSending => status == PaymentReminderStatus.sending;

  /// Returns a copy of the state.
  PaymentReminderState copyWith({
    PaymentReminderStatus? status,
    Object? errorMessage = _paymentReminderSentinel,
    Object? successMessage = _paymentReminderSentinel,
  }) {
    return PaymentReminderState(
      status: status ?? this.status,
      errorMessage: errorMessage == _paymentReminderSentinel
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _paymentReminderSentinel
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, errorMessage, successMessage];
}

const Object _paymentReminderSentinel = Object();

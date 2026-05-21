part of 'business_assistant_bloc.dart';

/// Events for [BusinessAssistantBloc].
sealed class BusinessAssistantEvent extends Equatable {
  const BusinessAssistantEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the greeting messages.
final class BusinessAssistantStarted extends BusinessAssistantEvent {
  const BusinessAssistantStarted();
}

/// Sends a text message from the user.
final class BusinessAssistantMessageSent extends BusinessAssistantEvent {
  const BusinessAssistantMessageSent({required this.text});

  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// Sends a recorded voice message from the user.
final class BusinessAssistantAudioSent extends BusinessAssistantEvent {
  const BusinessAssistantAudioSent({required this.audioPath});

  final String audioPath;

  @override
  List<Object?> get props => <Object?>[audioPath];
}

/// User tapped one candidate from the multi-match list — needs verification next.
final class BusinessAssistantCustomerPicked extends BusinessAssistantEvent {
  const BusinessAssistantCustomerPicked({required this.candidate});

  final ChatCustomerCandidate candidate;

  @override
  List<Object?> get props => <Object?>[candidate];
}

/// User confirmed the single verified candidate — proceed to record the transaction.
final class BusinessAssistantCustomerSelected extends BusinessAssistantEvent {
  const BusinessAssistantCustomerSelected({required this.customerId});

  final int customerId;

  @override
  List<Object?> get props => <Object?>[customerId];
}

/// User submitted a phone number (or "skip") for a new customer.
final class BusinessAssistantPhoneSubmitted extends BusinessAssistantEvent {
  const BusinessAssistantPhoneSubmitted({
    required this.customerName,
    required this.customerPhone,
  });

  final String customerName;

  /// Either a phone number string or the literal value `"skip"`.
  final String customerPhone;

  @override
  List<Object?> get props => <Object?>[customerName, customerPhone];
}

/// User rejected the suggested customer — clears pending state.
final class BusinessAssistantClarificationCancelled
    extends BusinessAssistantEvent {
  const BusinessAssistantClarificationCancelled();
}

/// User tapped "Other Customer" — wants to enter a different name + phone.
final class BusinessAssistantOtherCustomerRequested
    extends BusinessAssistantEvent {
  const BusinessAssistantOtherCustomerRequested();
}

/// User confirmed the transaction draft (possibly with edits).
final class BusinessAssistantDraftConfirmed extends BusinessAssistantEvent {
  const BusinessAssistantDraftConfirmed({
    required this.pendingTransaction,
    this.customerId,
    this.customerName,
    this.customerPhone,
  });

  final Map<String, dynamic> pendingTransaction;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;

  @override
  List<Object?> get props =>
      [pendingTransaction, customerId, customerName, customerPhone];
}

/// User cancelled the transaction draft (dismiss without recording).
final class BusinessAssistantDraftCancelled extends BusinessAssistantEvent {
  const BusinessAssistantDraftCancelled();
}

part of 'business_assistant_bloc.dart';

/// State for [BusinessAssistantBloc].
final class BusinessAssistantState extends Equatable {
  const BusinessAssistantState({
    required this.messages,
    this.isTyping = false,
    this.error,
    this.customerCandidates = const [],
    this.pendingTransaction,
    this.verifyingCandidate,
    this.detectedLanguage,
  });

  /// All chat messages, oldest first.
  final List<ChatMessageEntity> messages;

  /// True while the assistant is generating a reply.
  final bool isTyping;

  /// Non-null when the last operation failed.
  final String? error;

  /// Candidate list from backend — shown in selection widget.
  final List<ChatCustomerCandidate> customerCandidates;

  /// Serialised pending transaction to echo back to confirm-customer API.
  final Map<String, dynamic>? pendingTransaction;

  /// Set when the user picks one candidate from the list — triggers verification card.
  /// Distinct from [customerCandidates] so we can go back to the list on rejection.
  final ChatCustomerCandidate? verifyingCandidate;

  /// BCP-47 language tag detected by MuRIL for the most recent exchange
  /// (e.g. "hi-Latn", "hi-Deva", "en"). Shown in the AppBar language chip.
  final String? detectedLanguage;

  BusinessAssistantState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isTyping,
    String? error,
    List<ChatCustomerCandidate>? customerCandidates,
    Map<String, dynamic>? pendingTransaction,
    ChatCustomerCandidate? verifyingCandidate,
    String? detectedLanguage,
    bool clearPending = false,
    bool clearVerifying = false,
  }) {
    return BusinessAssistantState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      customerCandidates: customerCandidates ?? this.customerCandidates,
      pendingTransaction:
          clearPending ? null : (pendingTransaction ?? this.pendingTransaction),
      verifyingCandidate: clearVerifying
          ? null
          : (verifyingCandidate ?? this.verifyingCandidate),
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isTyping,
        error,
        customerCandidates,
        pendingTransaction,
        verifyingCandidate,
        detectedLanguage,
      ];
}

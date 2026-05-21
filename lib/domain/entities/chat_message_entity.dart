import 'package:apna_business_app/domain/entities/chat_transaction_entity.dart';
import 'package:apna_business_app/domain/entities/muril_analysis.dart';
import 'package:equatable/equatable.dart';

/// A single message in the Business Assistant chat.
class ChatMessageEntity extends Equatable {
  /// Creates a chat message.
  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.createdAt,
    this.audioPath,
    this.audioUrl,
    this.transactions = const [],
    this.confidence,
    this.clarificationNeeded,
    this.murilAnalysis,
    this.transactionDraft,
  });

  /// Unique identifier.
  final String id;

  /// Message body (may be empty when the message is audio-only from the user).
  final String text;

  /// True when sent by the user; false when from the assistant.
  final bool isFromUser;

  /// Timestamp of the message.
  final DateTime createdAt;

  /// Local path to a recorded voice message (user messages only).
  final String? audioPath;

  /// Remote URL to an AI-generated audio reply (assistant messages only).
  final String? audioUrl;

  /// Transactions recorded by the AI (assistant messages only).
  final List<ChatTransactionEntity> transactions;

  /// Confidence level reported by the AI (e.g. "high", "medium", "low").
  final String? confidence;

  /// Non-null when the AI needs additional input from the user.
  final String? clarificationNeeded;

  /// MuRIL analysis (intent, NER, language) returned by the backend pipeline.
  /// Present only on assistant messages; null on user messages and on backends
  /// that have not yet integrated MuRIL.
  final MurilAnalysis? murilAnalysis;

  /// Transaction draft — non-null when the AI has gathered all sale data and
  /// wants the user to review + confirm before recording.
  final TransactionDraftEntity? transactionDraft;

  /// True only for user voice messages (recorded locally).
  bool get isAudio => audioPath != null;

  @override
  List<Object?> get props => <Object?>[
        id,
        text,
        isFromUser,
        createdAt,
        audioPath,
        audioUrl,
        transactions,
        confidence,
        clarificationNeeded,
        murilAnalysis,
        transactionDraft,
      ];
}

import 'package:apna_business_app/domain/entities/chat_customer_candidate.dart';
import 'package:apna_business_app/domain/entities/chat_transaction_entity.dart';
import 'package:apna_business_app/domain/entities/muril_analysis.dart';

/// DTO for chat response.
class ChatResponseModel {
  /// Creates a chat response model.
  const ChatResponseModel({
    required this.reply,
    this.audioUrl,
    this.transactions = const [],
    this.confidence,
    this.clarificationNeeded,
    this.customerCandidates = const [],
    this.pendingTransaction,
    this.murilAnalysis,
    this.transactionDraft,
  });

  final String reply;
  final String? audioUrl;
  final List<ChatTransactionEntity> transactions;
  final String? confidence;
  final String? clarificationNeeded;
  final List<ChatCustomerCandidate> customerCandidates;
  final Map<String, dynamic>? pendingTransaction;
  final MurilAnalysis? murilAnalysis;
  final TransactionDraftEntity? transactionDraft;

  factory ChatResponseModel.fromJson(Map<String, Object?> json) {
    final rawTransactions = json['transactions'] as List<dynamic>? ?? [];
    final rawCandidates = json['customer_candidates'] as List<dynamic>? ?? [];
    final rawDraft = json['transaction_draft'] as Map<String, dynamic>?;
    return ChatResponseModel(
      reply: json['reply'] as String? ?? '',
      audioUrl: json['audio_url'] as String?,
      transactions: rawTransactions
          .map((t) => _parseTransaction(t as Map<String, dynamic>))
          .toList(),
      confidence: json['confidence'] as String?,
      clarificationNeeded: json['clarification_needed'] as String?,
      customerCandidates: rawCandidates
          .map((c) => ChatCustomerCandidate.fromJson(c as Map<String, dynamic>))
          .toList(),
      pendingTransaction: json['pending_transaction'] as Map<String, dynamic>?,
      murilAnalysis: json['muril_analysis'] != null
          ? MurilAnalysis.fromJson(
              json['muril_analysis'] as Map<String, dynamic>)
          : null,
      transactionDraft:
          rawDraft != null ? _parseDraft(rawDraft) : null,
    );
  }

  static TransactionDraftEntity _parseDraft(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return TransactionDraftEntity(
      type: map['type'] as String? ?? 'sale',
      customerName: map['customer_name'] as String?,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((i) => TransactionDraftItemEntity(
                name: i['name'] as String? ?? '',
                quantity: (i['quantity'] as num?)?.toDouble(),
                unit: i['unit'] as String?,
                ratePerUnit: (i['rate_per_unit'] as num?)?.toDouble(),
                subtotal: (i['subtotal'] as num?)?.toDouble() ?? 0.0,
                priceSource: i['price_source'] as String? ?? 'user',
              ))
          .toList(),
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (map['pending_amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: map['is_credit'] as bool? ?? false,
      note: map['note'] as String?,
    );
  }

  static ChatTransactionEntity _parseTransaction(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return ChatTransactionEntity(
      type: map['type'] as String? ?? '',
      status: map['status'] as String? ?? '',
      customerName: map['customer_name'] as String?,
      totalAmount: (map['total_amount'] as num?)?.toDouble(),
      amountPaid: (map['amount_paid'] as num?)?.toDouble(),
      pendingAmount: (map['pending_amount'] as num?)?.toDouble(),
      customerTotalPending: (map['customer_total_pending'] as num?)?.toDouble(),
      isCredit: map['is_credit'] as bool? ?? false,
      items: rawItems
          .map((i) => _parseItem(i as Map<String, dynamic>))
          .toList(),
      note: map['note'] as String?,
      message: map['message'] as String?,
    );
  }

  static ChatTransactionItemEntity _parseItem(Map<String, dynamic> map) {
    return ChatTransactionItemEntity(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String?,
      ratePerUnit: (map['rate_per_unit'] as num?)?.toDouble() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

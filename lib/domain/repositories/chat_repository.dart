import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/entities/chat_customer_candidate.dart';
import 'package:apna_business_app/domain/entities/chat_transaction_entity.dart';
import 'package:apna_business_app/domain/entities/muril_analysis.dart';
import 'package:dartz/dartz.dart';

/// Return record for all chat operations.
typedef ChatResult = ({
  String reply,
  String? audioUrl,
  List<ChatTransactionEntity> transactions,
  String? confidence,
  String? clarificationNeeded,
  List<ChatCustomerCandidate> customerCandidates,
  Map<String, dynamic>? pendingTransaction,
  MurilAnalysis? murilAnalysis,
  TransactionDraftEntity? transactionDraft,
});

/// Contract for chat operations.
abstract interface class ChatRepository {
  Future<Either<Failure, ChatResult>> sendMessage({required String message});

  Future<Either<Failure, ChatResult>> sendAudio({required String audioPath});

  Future<Either<Failure, ChatResult>> confirmCustomer({
    int? customerId,
    String? customerName,
    String? customerPhone,
    required Map<String, dynamic> pendingTransaction,
  });

  Future<Either<Failure, ChatResult>> confirmTransaction({
    required Map<String, dynamic> pendingTransaction,
    int? customerId,
    String? customerName,
    String? customerPhone,
  });
}

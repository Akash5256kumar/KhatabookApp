import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/data/datasources/remote/chat_remote_datasource.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation of [ChatRepository].
class ChatRepositoryImpl implements ChatRepository {
  /// Creates the repository.
  ChatRepositoryImpl(this._chatRemoteDataSource);

  final ChatRemoteDataSource _chatRemoteDataSource;

  @override
  Future<Either<Failure, ChatResult>> sendMessage({
    required String message,
  }) async {
    try {
      final response =
          await _chatRemoteDataSource.sendMessage(message: message);
      return Right(_toResult(response));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatResult>> sendAudio({
    required String audioPath,
  }) async {
    try {
      final response =
          await _chatRemoteDataSource.sendAudio(audioPath: audioPath);
      return Right(_toResult(response));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatResult>> confirmCustomer({
    int? customerId,
    String? customerName,
    String? customerPhone,
    required Map<String, dynamic> pendingTransaction,
  }) async {
    try {
      final response = await _chatRemoteDataSource.confirmCustomer(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        pendingTransaction: pendingTransaction,
      );
      return Right(_toResult(response));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatResult>> confirmTransaction({
    required Map<String, dynamic> pendingTransaction,
    int? customerId,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final response = await _chatRemoteDataSource.confirmTransaction(
        pendingTransaction: pendingTransaction,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
      );
      return Right(_toResult(response));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ChatResult _toResult(dynamic response) => (
        reply: response.reply as String,
        audioUrl: response.audioUrl as String?,
        transactions: response.transactions,
        confidence: response.confidence as String?,
        clarificationNeeded: response.clarificationNeeded as String?,
        customerCandidates: response.customerCandidates,
        pendingTransaction:
            response.pendingTransaction as Map<String, dynamic>?,
        murilAnalysis: response.murilAnalysis,
        transactionDraft: response.transactionDraft,
      );
}

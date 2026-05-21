import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/core/utils/nlp_preprocessor.dart';
import 'package:apna_business_app/data/datasources/remote/transcription_remote_datasource.dart';
import 'package:apna_business_app/data/models/chat_response_model.dart';
import 'package:dio/dio.dart';

/// Remote datasource for chat operations.
class ChatRemoteDataSource {
  /// Creates the datasource.
  ChatRemoteDataSource(this._dioClient, this._transcriptionDataSource);

  final DioClient _dioClient;
  final TranscriptionRemoteDataSource _transcriptionDataSource;

  /// Sends a text message to the chat API with an NLP-enriched payload.
  ///
  /// The payload includes the MuRIL pre-processor output so the backend can
  /// skip duplicate script detection and use the normalised text directly:
  ///   - `message`   — normalised text (LLM input)
  ///   - `raw_text`  — original user input (MuRIL NER input)
  ///   - `script`    — detected script ("devanagari" | "latin" | "mixed")
  ///   - `lang_hint` — BCP-47 hint for MuRIL language routing
  Future<ChatResponseModel> sendMessage({required String message}) async {
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/chat/',
        data: NlpPreprocessor.buildPayload(message),
      );
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Transcribes [audioPath] via Whisper, then forwards the text to the chat API.
  ///
  /// The original language (Hindi / English / Hinglish) is preserved because
  /// Whisper auto-detects the language when no explicit locale is passed.
  Future<ChatResponseModel> sendAudio({required String audioPath}) async {
    final transcribedText =
        await _transcriptionDataSource.transcribeAudio(audioPath);
    return sendMessage(message: transcribedText);
  }

  /// Confirms a customer after the backend requested clarification and
  /// completes the pending transaction.
  Future<ChatResponseModel> confirmCustomer({
    int? customerId,
    String? customerName,
    String? customerPhone,
    required Map<String, dynamic> pendingTransaction,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'customer_id': customerId,
        'pending_transaction': pendingTransaction,
      };
      if (customerId == null) {
        body['customer_name'] = customerName;
        body['customer_phone'] = customerPhone;
      }
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/chat/confirm-customer/',
        data: body,
      );
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Confirms a drafted transaction from the summary card.
  Future<ChatResponseModel> confirmTransaction({
    required Map<String, dynamic> pendingTransaction,
    int? customerId,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'pending_transaction': pendingTransaction,
        if (customerId != null) 'customer_id': customerId,
        if (customerName != null) 'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
      };
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/chat/confirm-transaction/',
        data: body,
      );
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  ChatResponseModel _parseResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ServerException('Empty response from server');
    }
    return ChatResponseModel.fromJson(data);
  }
}

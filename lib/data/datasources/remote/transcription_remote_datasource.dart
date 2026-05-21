import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

/// Calls the backend ElevenLabs Speech-to-Text endpoint to transcribe audio.
class TranscriptionRemoteDataSource {
  TranscriptionRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Transcribes the audio file at [audioPath] and returns the raw text.
  Future<String> transcribeAudio(String audioPath) async {
    try {
      final formData = FormData.fromMap(<String, dynamic>{
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        ),
      });

      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/api/v1/chat/transcribe/',
        data: formData,
      );

      final text = response.data?['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw const ServerException('Empty transcription returned');
      }
      return text.trim();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

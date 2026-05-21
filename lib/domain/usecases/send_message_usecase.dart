import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Use case for sending a text or audio message to the AI assistant.
class SendMessageUseCase {
  /// Creates the use case.
  SendMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  /// Sends a text or audio message and returns the full AI response.
  Future<Either<Failure, ChatResult>> call(
    SendMessageParams params,
  ) async {
    if (params.audioPath != null) {
      return _chatRepository.sendAudio(audioPath: params.audioPath!);
    }
    return _chatRepository.sendMessage(message: params.message ?? '');
  }
}

/// Parameters for [SendMessageUseCase].
class SendMessageParams extends Equatable {
  /// Creates text message parameters.
  const SendMessageParams.text(this.message) : audioPath = null;

  /// Creates audio message parameters.
  const SendMessageParams.audio(String path)
      : audioPath = path,
        message = null;

  /// Text message content (null when sending audio).
  final String? message;

  /// Local path to a recorded audio file (null when sending text).
  final String? audioPath;

  @override
  List<Object?> get props => [message, audioPath];
}

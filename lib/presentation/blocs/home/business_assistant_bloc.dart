import 'package:apna_business_app/domain/entities/chat_customer_candidate.dart';
import 'package:apna_business_app/domain/entities/chat_message_entity.dart';
import 'package:apna_business_app/domain/repositories/chat_repository.dart';
import 'package:apna_business_app/domain/usecases/confirm_customer_usecase.dart';
import 'package:apna_business_app/domain/usecases/confirm_transaction_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_message_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'business_assistant_event.dart';
part 'business_assistant_state.dart';

/// Manages the Business Assistant chat conversation.
class BusinessAssistantBloc
    extends Bloc<BusinessAssistantEvent, BusinessAssistantState> {
  BusinessAssistantBloc({
    required SendMessageUseCase sendMessageUseCase,
    required ConfirmCustomerUseCase confirmCustomerUseCase,
    required ConfirmTransactionUseCase confirmTransactionUseCase,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _confirmCustomerUseCase = confirmCustomerUseCase,
        _confirmTransactionUseCase = confirmTransactionUseCase,
        super(const BusinessAssistantState(messages: <ChatMessageEntity>[])) {
    on<BusinessAssistantStarted>(_onStarted);
    on<BusinessAssistantMessageSent>(_onMessageSent);
    on<BusinessAssistantAudioSent>(_onAudioSent);
    on<BusinessAssistantCustomerPicked>(_onCustomerPicked);
    on<BusinessAssistantCustomerSelected>(_onCustomerSelected);
    on<BusinessAssistantPhoneSubmitted>(_onPhoneSubmitted);
    on<BusinessAssistantClarificationCancelled>(_onClarificationCancelled);
    on<BusinessAssistantOtherCustomerRequested>(_onOtherCustomerRequested);
    on<BusinessAssistantDraftConfirmed>(_onDraftConfirmed);
    on<BusinessAssistantDraftCancelled>(_onDraftCancelled);
  }

  final SendMessageUseCase _sendMessageUseCase;
  final ConfirmCustomerUseCase _confirmCustomerUseCase;
  final ConfirmTransactionUseCase _confirmTransactionUseCase;
  int _messageCounter = 0;

  String _nextId() => 'msg-${++_messageCounter}';

  void _onStarted(
    BusinessAssistantStarted event,
    Emitter<BusinessAssistantState> emit,
  ) {
    emit(
      state.copyWith(
        messages: <ChatMessageEntity>[
          ChatMessageEntity(
            id: _nextId(),
            text:
                'Namaste! Main aapka Business Assistant hoon. Payments, reminders, ya reports — kuch bhi poochein.',
            isFromUser: false,
            createdAt: DateTime.now(),
          ),
        ],
      ),
    );
  }

  Future<void> _onMessageSent(
    BusinessAssistantMessageSent event,
    Emitter<BusinessAssistantState> emit,
  ) async {
    final String trimmed = event.text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessageEntity(
      id: _nextId(),
      text: trimmed,
      isFromUser: true,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      customerCandidates: [],
      clearPending: true,
      clearVerifying: true,
    ));

    final result = await _sendMessageUseCase(SendMessageParams.text(trimmed));
    _handleResult(result, emit);
  }

  Future<void> _onAudioSent(
    BusinessAssistantAudioSent event,
    Emitter<BusinessAssistantState> emit,
  ) async {
    final userMsg = ChatMessageEntity(
      id: _nextId(),
      text: '',
      isFromUser: true,
      createdAt: DateTime.now(),
      audioPath: event.audioPath,
    );

    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      customerCandidates: [],
      clearPending: true,
      clearVerifying: true,
    ));

    final result =
        await _sendMessageUseCase(SendMessageParams.audio(event.audioPath));
    _handleResult(result, emit);
  }

  void _onCustomerPicked(
    BusinessAssistantCustomerPicked event,
    Emitter<BusinessAssistantState> emit,
  ) {
    // Store the picked candidate for verification — keep the original candidate
    // list so the user can go back to it if they reject the verification.
    emit(state.copyWith(verifyingCandidate: event.candidate));
  }

  Future<void> _onCustomerSelected(
    BusinessAssistantCustomerSelected event,
    Emitter<BusinessAssistantState> emit,
  ) async {
    final pending = state.pendingTransaction;
    if (pending == null) return;

    emit(state.copyWith(
      customerCandidates: [],
      clearPending: true,
      clearVerifying: true,
      isTyping: true,
    ));

    final result = await _confirmCustomerUseCase(
      ConfirmCustomerParams.existing(
        customerId: event.customerId,
        pendingTransaction: pending,
      ),
    );
    _handleResult(result, emit);
  }

  Future<void> _onPhoneSubmitted(
    BusinessAssistantPhoneSubmitted event,
    Emitter<BusinessAssistantState> emit,
  ) async {
    final pending = state.pendingTransaction;
    if (pending == null) return;

    emit(state.copyWith(
      customerCandidates: [],
      clearPending: true,
      clearVerifying: true,
      isTyping: true,
    ));

    final result = await _confirmCustomerUseCase(
      ConfirmCustomerParams.newCustomer(
        customerName: event.customerName,
        customerPhone: event.customerPhone,
        pendingTransaction: pending,
      ),
    );
    _handleResult(result, emit);
  }

  void _onOtherCustomerRequested(
    BusinessAssistantOtherCustomerRequested event,
    Emitter<BusinessAssistantState> emit,
  ) {
    emit(state.copyWith(customerCandidates: [], clearVerifying: true));
  }

  Future<void> _onDraftConfirmed(
    BusinessAssistantDraftConfirmed event,
    Emitter<BusinessAssistantState> emit,
  ) async {
    emit(state.copyWith(isTyping: true, customerCandidates: [], clearVerifying: true));
    final result = await _confirmTransactionUseCase(
      ConfirmTransactionParams(
        pendingTransaction: event.pendingTransaction,
        customerId: event.customerId,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
      ),
    );
    _handleResult(result, emit);
  }

  void _onDraftCancelled(
    BusinessAssistantDraftCancelled event,
    Emitter<BusinessAssistantState> emit,
  ) {
    emit(state.copyWith(clearPending: true, customerCandidates: [], clearVerifying: true));
  }

  void _onClarificationCancelled(
    BusinessAssistantClarificationCancelled event,
    Emitter<BusinessAssistantState> emit,
  ) {
    // Clear verifyingCandidate — returns user to the selection list.
    emit(state.copyWith(clearVerifying: true));
  }

  void _handleResult(
    dynamic result,
    Emitter<BusinessAssistantState> emit,
  ) {
    result.fold(
      (failure) {
        final errorMsg = ChatMessageEntity(
          id: _nextId(),
          text: 'Sorry, something went wrong. Please try again.',
          isFromUser: false,
          createdAt: DateTime.now(),
        );
        emit(state.copyWith(
          messages: [...state.messages, errorMsg],
          isTyping: false,
          error: failure.message,
          customerCandidates: [],
          clearPending: true,
          clearVerifying: true,
        ));
      },
      (ChatResult data) {
        final replyMsg = ChatMessageEntity(
          id: _nextId(),
          text: data.reply,
          isFromUser: false,
          createdAt: DateTime.now(),
          audioUrl: data.audioUrl,
          transactions: data.transactions,
          confidence: data.confidence,
          clarificationNeeded: data.clarificationNeeded,
          murilAnalysis: data.murilAnalysis,
          transactionDraft: data.transactionDraft,
        );
        emit(state.copyWith(
          messages: [...state.messages, replyMsg],
          isTyping: false,
          customerCandidates: data.customerCandidates,
          pendingTransaction: data.pendingTransaction,
          clearPending: data.pendingTransaction == null,
          clearVerifying: true,
          detectedLanguage: data.murilAnalysis?.detectedLanguage,
        ));
      },
    );
  }
}

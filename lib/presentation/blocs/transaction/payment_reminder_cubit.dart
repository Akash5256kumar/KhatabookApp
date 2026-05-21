import 'package:apna_business_app/core/errors/failure.dart';
import 'package:apna_business_app/domain/usecases/send_reminder_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_reminder_state.dart';

/// Sends a single WhatsApp reminder from the composer screen.
class PaymentReminderCubit extends Cubit<PaymentReminderState> {
  /// Creates the cubit.
  PaymentReminderCubit({
    required SendReminderUseCase sendReminderUseCase,
  })  : _sendReminderUseCase = sendReminderUseCase,
        super(const PaymentReminderState());

  final SendReminderUseCase _sendReminderUseCase;

  /// Sends a WhatsApp reminder after local validation.
  Future<void> sendReminder({
    required String customerId,
    required String message,
    required String phone,
    required double balance,
  }) async {
    final String trimmedMessage = message.trim();
    if (phone.trim().isEmpty) {
      emit(
        state.copyWith(
          status: PaymentReminderStatus.failure,
          errorMessage:
              'Customer phone number is required to send a WhatsApp reminder.',
        ),
      );
      return;
    }
    if (balance <= 0) {
      emit(
        state.copyWith(
          status: PaymentReminderStatus.failure,
          errorMessage: 'This customer has no pending amount to remind.',
        ),
      );
      return;
    }
    if (trimmedMessage.isEmpty) {
      emit(
        state.copyWith(
          status: PaymentReminderStatus.failure,
          errorMessage: 'Reminder message cannot be empty.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PaymentReminderStatus.sending,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await _sendReminderUseCase(
      customerId: customerId,
      message: trimmedMessage,
    );
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: PaymentReminderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: PaymentReminderStatus.success,
          successMessage: response.message,
          errorMessage: null,
        ),
      ),
    );
  }
}

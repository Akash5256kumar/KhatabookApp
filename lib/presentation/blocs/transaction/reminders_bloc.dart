import 'package:apna_business_app/core/utils/reminder_message_builder.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/reminder_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_overview_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_send_result_entity.dart';
import 'package:apna_business_app/domain/entities/reminder_settings_entity.dart';
import 'package:apna_business_app/domain/usecases/fetch_reminders_usecase.dart';
import 'package:apna_business_app/domain/usecases/send_reminder_usecase.dart';
import 'package:apna_business_app/domain/usecases/update_reminder_settings_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reminders_event.dart';
part 'reminders_state.dart';

/// Manages payment reminders and auto-alert settings.
class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  /// Creates the bloc.
  RemindersBloc({
    required FetchRemindersUseCase fetchRemindersUseCase,
    required UpdateReminderSettingsUseCase updateReminderSettingsUseCase,
    required SendReminderUseCase sendReminderUseCase,
  })  : _fetchRemindersUseCase = fetchRemindersUseCase,
        _updateReminderSettingsUseCase = updateReminderSettingsUseCase,
        _sendReminderUseCase = sendReminderUseCase,
        super(const RemindersInitial()) {
    on<RemindersStarted>(_onStarted);
    on<RemindersRefreshed>(_onRefreshed);
    on<RemindersAutoAlertToggled>(_onAutoAlertToggled);
    on<RemindersSendRequested>(_onSendRequested);
  }

  final FetchRemindersUseCase _fetchRemindersUseCase;
  final UpdateReminderSettingsUseCase _updateReminderSettingsUseCase;
  final SendReminderUseCase _sendReminderUseCase;

  Future<void> _onStarted(
    RemindersStarted event,
    Emitter<RemindersState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefreshed(
    RemindersRefreshed event,
    Emitter<RemindersState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onAutoAlertToggled(
    RemindersAutoAlertToggled event,
    Emitter<RemindersState> emit,
  ) async {
    final RemindersState current = state;
    if (current is! RemindersSuccess || current.isUpdatingSettings) return;

    emit(
      current.copyWith(
        isUpdatingSettings: true,
        feedbackMessage: null,
        errorMessage: null,
      ),
    );
    final result = await _updateReminderSettingsUseCase(enabled: event.enabled);
    result.fold(
      (failure) => emit(
        current.copyWith(
          isUpdatingSettings: false,
          errorMessage: failure.message,
        ),
      ),
      (ReminderSettingsEntity settings) => emit(
        current.copyWith(
          autoAlertsEnabled: settings.whatsAppAutoEnabled,
          isUpdatingSettings: false,
          feedbackMessage: settings.message,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onSendRequested(
    RemindersSendRequested event,
    Emitter<RemindersState> emit,
  ) async {
    final RemindersState current = state;
    if (current is! RemindersSuccess) return;
    final ReminderEntity reminder = current.reminders.firstWhere(
      (ReminderEntity item) => item.id == event.reminderId,
    );
    if (!reminder.canSendOnWhatsApp) {
      emit(
        current.copyWith(
          errorMessage: reminder.validationMessage ??
              'Customer phone number is required to send a WhatsApp reminder.',
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        sendingId: event.reminderId,
        feedbackMessage: null,
        errorMessage: null,
      ),
    );

    final String message = event.customMessage?.trim().isNotEmpty == true
        ? event.customMessage!.trim()
        : buildReminderMessage(
            customerName: reminder.customerName,
            formattedAmount: reminder.amount.toInr,
          );
    final result = await _sendReminderUseCase(
      customerId: event.reminderId,
      message: message,
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          sendingId: null,
          errorMessage: failure.message,
        ),
      ),
      (ReminderSendResultEntity response) {
        final List<ReminderEntity> updated = current.reminders
            .map(
              (ReminderEntity item) => item.id == event.reminderId
                  ? response.reminder
                  : item,
            )
            .toList(growable: false);
        emit(
          current.copyWith(
            reminders: updated,
            sendingId: null,
            feedbackMessage: response.message,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _load(Emitter<RemindersState> emit) async {
    emit(const RemindersLoading());
    final result = await _fetchRemindersUseCase();
    result.fold(
      (failure) => emit(RemindersFailure(failure.message)),
      (ReminderOverviewEntity overview) {
        if (overview.reminders.isEmpty) {
          emit(const RemindersEmpty());
          return;
        }
        emit(
          RemindersSuccess(
            reminders: overview.reminders,
            autoAlertsEnabled: overview.whatsAppAutoEnabled,
          ),
        );
      },
    );
  }
}

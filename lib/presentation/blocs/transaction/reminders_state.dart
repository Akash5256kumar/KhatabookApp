part of 'reminders_bloc.dart';

/// States for [RemindersBloc].
sealed class RemindersState extends Equatable {
  const RemindersState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Pre-load state.
final class RemindersInitial extends RemindersState {
  /// Creates the state.
  const RemindersInitial();
}

/// Loading spinner.
final class RemindersLoading extends RemindersState {
  /// Creates the state.
  const RemindersLoading();
}

/// Reminders list available.
final class RemindersSuccess extends RemindersState {
  /// Creates the state.
  const RemindersSuccess({
    required this.reminders,
    required this.autoAlertsEnabled,
    this.sendingId,
    this.isUpdatingSettings = false,
    this.feedbackMessage,
    this.errorMessage,
  });

  /// Loaded reminders.
  final List<ReminderEntity> reminders;

  /// Whether automatic payment reminders are enabled.
  final bool autoAlertsEnabled;

  /// The ID of the reminder currently being sent (null = none).
  final String? sendingId;

  /// Whether the WhatsApp auto-send switch is saving.
  final bool isUpdatingSettings;

  /// Optional success message for UI feedback.
  final String? feedbackMessage;

  /// Optional action-level error message.
  final String? errorMessage;

  /// Returns a copy with the given fields replaced.
  RemindersSuccess copyWith({
    List<ReminderEntity>? reminders,
    bool? autoAlertsEnabled,
    Object? sendingId = _sentinel,
    bool? isUpdatingSettings,
    Object? feedbackMessage = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return RemindersSuccess(
      reminders: reminders ?? this.reminders,
      autoAlertsEnabled: autoAlertsEnabled ?? this.autoAlertsEnabled,
      sendingId: sendingId == _sentinel ? this.sendingId : sendingId as String?,
      isUpdatingSettings: isUpdatingSettings ?? this.isUpdatingSettings,
      feedbackMessage: feedbackMessage == _sentinel
          ? this.feedbackMessage
          : feedbackMessage as String?,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[
        reminders,
        autoAlertsEnabled,
        sendingId,
        isUpdatingSettings,
        feedbackMessage,
        errorMessage,
      ];
}

/// No reminders found.
final class RemindersEmpty extends RemindersState {
  /// Creates the state.
  const RemindersEmpty();
}

/// Error loading reminders.
final class RemindersFailure extends RemindersState {
  /// Creates the state.
  const RemindersFailure(this.message);

  /// Human-readable error.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

const Object _sentinel = Object();

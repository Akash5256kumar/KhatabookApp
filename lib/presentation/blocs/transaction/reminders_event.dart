part of 'reminders_bloc.dart';

/// Events for [RemindersBloc].
sealed class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Bootstraps the reminders list.
final class RemindersStarted extends RemindersEvent {
  /// Creates the event.
  const RemindersStarted();
}

/// Refreshes the list.
final class RemindersRefreshed extends RemindersEvent {
  /// Creates the event.
  const RemindersRefreshed();
}

/// Toggles the auto-alerts setting.
final class RemindersAutoAlertToggled extends RemindersEvent {
  /// Creates the event.
  const RemindersAutoAlertToggled({required this.enabled});

  /// New value for auto-alerts.
  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

/// Sends a manual reminder to a specific customer.
final class RemindersSendRequested extends RemindersEvent {
  /// Creates the event.
  const RemindersSendRequested({
    required this.reminderId,
    this.customMessage,
  });

  /// Identifier of the reminder to send.
  final String reminderId;

  /// Optional custom message to send instead of the default template.
  final String? customMessage;

  @override
  List<Object?> get props => <Object?>[reminderId, customMessage];
}

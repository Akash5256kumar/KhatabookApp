import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/date_extension.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/reminder_entity.dart';
import 'package:apna_business_app/presentation/blocs/transaction/reminders_bloc.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen showing payment reminders with auto-alert controls.
class RemindersScreen extends StatelessWidget {
  /// Creates the screen.
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Reminders'),
        centerTitle: false,
      ),
      body: BlocConsumer<RemindersBloc, RemindersState>(
        listener: (BuildContext context, RemindersState state) {
          if (state is RemindersFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (state is RemindersSuccess) {
            final String? feedback = state.errorMessage ?? state.feedbackMessage;
            if (feedback != null && feedback.isNotEmpty) {
              final bool isError = state.errorMessage != null;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(feedback),
                    backgroundColor: isError ? AppColors.expense : null,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          }
        },
        builder: (BuildContext context, RemindersState state) {
          return switch (state) {
            RemindersLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            RemindersEmpty() => const EmptyStateView(
                title: 'No pending reminders',
                message:
                    'Jab bhi koi customer late payment karega, yahan reminder dikhega.',
              ),
            RemindersFailure() => BrandedErrorView(
                message: state.message,
                onRetry: () => context
                    .read<RemindersBloc>()
                    .add(const RemindersRefreshed()),
              ),
            RemindersSuccess() => _RemindersContent(state: state),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _RemindersContent extends StatelessWidget {
  const _RemindersContent({required this.state});

  final RemindersSuccess state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSM),
      itemCount: state.reminders.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _AutoAlertBanner(
            autoAlertsEnabled: state.autoAlertsEnabled,
            isUpdatingSettings: state.isUpdatingSettings,
          );
        }
        return _ReminderCard(
          reminder: state.reminders[index - 1],
          isSending: state.sendingId == state.reminders[index - 1].id,
        );
      },
    );
  }
}

class _AutoAlertBanner extends StatelessWidget {
  const _AutoAlertBanner({
    required this.autoAlertsEnabled,
    required this.isUpdatingSettings,
  });

  final bool autoAlertsEnabled;
  final bool isUpdatingSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.spaceMD,
        AppDimensions.pagePadding,
        AppDimensions.spaceXXL,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Auto Reminders', style: AppTextStyles.title),
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Text(
                      autoAlertsEnabled
                          ? 'Due customers ko automatically WhatsApp reminder jayega'
                          : 'Auto reminders band hain',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoAlertsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: isUpdatingSettings
                    ? null
                    : (bool value) => context
                        .read<RemindersBloc>()
                        .add(RemindersAutoAlertToggled(enabled: value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.isSending,
  });

  final ReminderEntity reminder;
  final bool isSending;

  Color _statusColor() {
    return switch (reminder.status) {
      ReminderStatus.pending => AppColors.expense,
      ReminderStatus.sent => AppColors.payment,
      ReminderStatus.paid => AppColors.sale,
    };
  }

  String _statusLabel() {
    return switch (reminder.status) {
      ReminderStatus.pending => 'Pending',
      ReminderStatus.sent => 'Sent',
      ReminderStatus.paid => 'Paid',
    };
  }

  bool get _isOverdue =>
      reminder.status == ReminderStatus.pending &&
      reminder.dueDate.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        0,
        AppDimensions.pagePadding,
        AppDimensions.spaceMD,
      ),
      child: Card(
        shape: _isOverdue
            ? RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLG),
                side: const BorderSide(color: AppColors.expense, width: 1),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      reminder.customerName.initials,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          reminder.customerName,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          reminder.phone ?? 'WhatsApp number missing',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceSM,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor().withAlpha(25),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: AppTextStyles.label.copyWith(
                        color: _statusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: AppDimensions.spaceXXL),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Amount Due', style: AppTextStyles.bodyMuted),
                        const SizedBox(height: 2),
                        Text(
                          reminder.amount.toInr,
                          style: AppTextStyles.title,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _isOverdue ? 'Overdue Since' : 'Due Date',
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reminder.dueDate.displayDate,
                          style: AppTextStyles.title.copyWith(
                            color: _isOverdue ? AppColors.expense : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reminder.lastSentAt != null) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  'Last WhatsApp reminder: ${reminder.lastSentAt!.displayDateTime}',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
              if (!reminder.canSendOnWhatsApp &&
                  reminder.validationMessage != null) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  reminder.validationMessage!,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.expense,
                  ),
                ),
              ],
              if (reminder.status == ReminderStatus.pending) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceMD),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSending || !reminder.canSendOnWhatsApp
                        ? null
                        : () => context.read<RemindersBloc>().add(
                              RemindersSendRequested(
                                reminderId: reminder.id,
                              ),
                            ),
                    icon: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(
                      isSending ? 'Sending on WhatsApp...' : 'Send on WhatsApp',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

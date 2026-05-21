import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/core/utils/reminder_message_builder.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/presentation/blocs/transaction/payment_reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen for composing and sending a WhatsApp payment reminder.
class PaymentReminderScreen extends StatefulWidget {
  /// Creates the screen.
  const PaymentReminderScreen({
    required this.customer,
    super.key,
  });

  /// Customer to remind.
  final CustomerEntity customer;

  @override
  State<PaymentReminderScreen> createState() => _PaymentReminderScreenState();
}

class _PaymentReminderScreenState extends State<PaymentReminderScreen> {
  late final TextEditingController _messageController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _defaultMessage());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _defaultMessage() {
    return buildReminderMessage(
      customerName: widget.customer.name,
      formattedAmount: widget.customer.balance.abs().toInr,
    );
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (_isEditing) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _sendOnWhatsApp() {
    context.read<PaymentReminderCubit>().sendReminder(
      customerId: widget.customer.id,
      message: _messageController.text,
      phone: widget.customer.phone,
      balance: widget.customer.balance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Payment Reminder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<PaymentReminderCubit, PaymentReminderState>(
        listener: (BuildContext context, PaymentReminderState state) {
          final String? message = state.errorMessage ?? state.successMessage;
          if (message == null || message.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: state.status == PaymentReminderStatus.failure
                    ? AppColors.expense
                    : null,
              ),
            );
        },
        builder: (BuildContext context, PaymentReminderState state) {
          final bool canSend = widget.customer.phone.trim().isNotEmpty &&
              widget.customer.balance > 0;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SendingToCard(customer: widget.customer),
                const SizedBox(height: AppDimensions.spaceLG),
                if (!canSend)
                  _ValidationCard(
                    message: widget.customer.phone.trim().isEmpty
                        ? 'Customer phone number missing hai. WhatsApp reminder bhejne ke liye number add karein.'
                        : 'Pending balance zero hai, is customer ko reminder nahi bheja ja sakta.',
                  ),
                if (!canSend) const SizedBox(height: AppDimensions.spaceLG),
                _MessagePreviewCard(
                  controller: _messageController,
                  focusNode: _focusNode,
                  isEditing: _isEditing,
                  onToggleEdit: _toggleEdit,
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                _WhatsAppButton(
                  onTap: _sendOnWhatsApp,
                  isLoading: state.isSending,
                  isEnabled:
                      canSend && state.status != PaymentReminderStatus.success,
                  isSuccess: state.status == PaymentReminderStatus.success,
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                _CancelButton(onTap: () => context.pop()),
                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SendingToCard extends StatelessWidget {
  const _SendingToCard({required this.customer});

  final CustomerEntity customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Sending to:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6D7C74),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            customer.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF18233A),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXXS),
          Text(
            customer.phone,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6D7C74),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePreviewCard extends StatelessWidget {
  const _MessagePreviewCard({
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.onToggleEdit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF7F1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header row: icon + title + Edit/Done button
          Row(
            children: <Widget>[
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              const Expanded(
                child: Text(
                  'WhatsApp Message Preview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF18233A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggleEdit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isEditing
                          ? Icons.check_rounded
                          : Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppDimensions.spaceXXS),
                    Text(
                      isEditing ? 'Done' : 'Edit',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          // Message text area
          Container(
            constraints: const BoxConstraints(minHeight: 160),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                color: const Color(0xFFCDE9D8),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: !isEditing,
              maxLines: null,
              minLines: 7,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF18233A),
                height: 1.6,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({
    required this.onTap,
    required this.isLoading,
    required this.isEnabled,
    required this.isSuccess,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onTap : null,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.chat_bubble_outline_rounded,
                size: 20,
              ),
        label: Text(
          isLoading
              ? 'Sending on WhatsApp...'
              : isSuccess
                  ? 'Sent on WhatsApp'
                  : 'Send on WhatsApp',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.expense.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: AppColors.expense),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7A281B),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEEEEE),
          foregroundColor: const Color(0xFF18233A),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

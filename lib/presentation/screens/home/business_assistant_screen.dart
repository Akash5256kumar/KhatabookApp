import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/date_extension.dart';
import 'package:apna_business_app/domain/entities/chat_customer_candidate.dart';
import 'package:apna_business_app/domain/entities/chat_message_entity.dart';
import 'package:apna_business_app/domain/entities/chat_transaction_entity.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/domain/entities/muril_analysis.dart';
import 'package:apna_business_app/injection/injection_container.dart';
import 'package:apna_business_app/presentation/blocs/home/business_assistant_bloc.dart';
import 'package:apna_business_app/presentation/blocs/inventory/inventory_bloc.dart';
import 'package:apna_business_app/presentation/screens/home/widgets/transaction_draft_card.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class BusinessAssistantScreen extends StatefulWidget {
  const BusinessAssistantScreen({super.key});

  @override
  State<BusinessAssistantScreen> createState() =>
      _BusinessAssistantScreenState();
}

class _BusinessAssistantScreenState extends State<BusinessAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _playingMessageId;

  @override
  void initState() {
    super.initState();
    context.read<BusinessAssistantBloc>().add(const BusinessAssistantStarted());
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        if (mounted) setState(() => _playingMessageId = null);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sendTextMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    context
        .read<BusinessAssistantBloc>()
        .add(BusinessAssistantMessageSent(text: text));
    _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null && mounted) {
        context
            .read<BusinessAssistantBloc>()
            .add(BusinessAssistantAudioSent(audioPath: path));
        _scrollToBottom();
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required')),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _toggleAudioPlayback(ChatMessageEntity message) async {
    if (_playingMessageId == message.id) {
      await _audioPlayer.stop();
      setState(() => _playingMessageId = null);
      return;
    }
    setState(() => _playingMessageId = message.id);
    if (message.audioUrl != null) {
      await _audioPlayer.play(UrlSource(message.audioUrl!));
    } else if (message.audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(message.audioPath!));
    }
  }

  bool _hasClarificationWidget(BusinessAssistantState state) {
    return state.verifyingCandidate != null ||
        state.customerCandidates.isNotEmpty ||
        state.pendingTransaction != null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDimensions.mediumDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InventoryBloc>(
      create: (_) => getIt<InventoryBloc>()..add(const InventoryStarted()),
      child: Builder(builder: (ctx) => _buildScaffold(ctx)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Business Assistant', style: AppTextStyles.title),
                Text(
                  'AI-powered help',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          BlocSelector<BusinessAssistantBloc, BusinessAssistantState, String?>(
            selector: (state) => state.detectedLanguage,
            builder: (context, lang) {
              if (lang == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spaceMD),
                child: _LanguageChip(language: lang),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BusinessAssistantBloc, BusinessAssistantState>(
        listener: (context, state) => _scrollToBottom(),
        builder: (context, state) {
          return Column(
            children: <Widget>[
              if (_isRecording) const _RecordingBanner(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  itemCount: state.messages.length +
                      (state.isTyping ? 1 : 0) +
                      (_hasClarificationWidget(state) ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isTyping && index == state.messages.length) {
                      return const _TypingIndicator();
                    }

                    final clarificationIndex =
                        state.messages.length + (state.isTyping ? 1 : 0);
                    if (_hasClarificationWidget(state) &&
                        index == clarificationIndex) {
                      // Priority 1: user picked a candidate → show verification
                      if (state.verifyingCandidate != null) {
                        final candidate = state.verifyingCandidate!;
                        return _CustomerVerificationWidget(
                          candidate: candidate,
                          onConfirm: () => context
                              .read<BusinessAssistantBloc>()
                              .add(BusinessAssistantCustomerSelected(
                                  customerId: candidate.id)),
                          // Reject goes back to selection list
                          onReject: () => context
                              .read<BusinessAssistantBloc>()
                              .add(
                                  const BusinessAssistantClarificationCancelled()),
                        );
                      }

                      // Priority 2: backend returned candidates → always show list
                      // (even for single match — user must explicitly pick)
                      if (state.customerCandidates.isNotEmpty) {
                        return _CustomerSelectionWidget(
                          candidates: state.customerCandidates,
                          onSelected: (candidate) => context
                              .read<BusinessAssistantBloc>()
                              .add(BusinessAssistantCustomerPicked(
                                  candidate: candidate)),
                          onOtherCustomer: () => context
                              .read<BusinessAssistantBloc>()
                              .add(
                                  const BusinessAssistantOtherCustomerRequested()),
                        );
                      }

                      // Priority 3: no candidates → name+phone form
                      final prefillName =
                          state.pendingTransaction?['customer_name']
                                  as String? ??
                              '';
                      return _PhoneInputWidget(
                        prefillName: prefillName,
                        onSubmit: (name, phone) => context
                            .read<BusinessAssistantBloc>()
                            .add(BusinessAssistantPhoneSubmitted(
                              customerName: name,
                              customerPhone: phone,
                            )),
                      );
                    }

                    final msg = state.messages[index];
                    return _ChatBubble(
                      message: msg,
                      isPlaying: _playingMessageId == msg.id,
                      onPlayTap: (msg.isAudio || msg.audioUrl != null)
                          ? () => _toggleAudioPlayback(msg)
                          : null,
                    );
                  },
                ),
              ),
              _QuickReplyBar(
                onTap: (text) {
                  _inputController.clear();
                  context
                      .read<BusinessAssistantBloc>()
                      .add(BusinessAssistantMessageSent(text: text));
                  _scrollToBottom();
                },
              ),
              _InputBar(
                controller: _inputController,
                isRecording: _isRecording,
                onSend: _sendTextMessage,
                onMicTap: _toggleRecording,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Recording banner ──────────────────────────────────────────────────────────

class _RecordingBanner extends StatelessWidget {
  const _RecordingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceLG,
        vertical: AppDimensions.spaceSM,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.mic, color: Colors.red, size: 16),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            'Recording… tap mic to send',
            style: AppTextStyles.label.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isPlaying,
    this.onPlayTap,
  });

  final ChatMessageEntity message;
  final bool isPlaying;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isFromUser;
    final bool hasTransactions = message.transactions.isNotEmpty;
    final Color bubbleColor = isUser
        ? AppColors.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color textColor =
        isUser ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.smart_toy_outlined,
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        (hasTransactions ? 0.92 : 0.72),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          const Radius.circular(AppDimensions.radiusLG),
                      topRight:
                          const Radius.circular(AppDimensions.radiusLG),
                      bottomLeft: Radius.circular(
                        isUser
                            ? AppDimensions.radiusLG
                            : AppDimensions.radiusSM,
                      ),
                      bottomRight: Radius.circular(
                        isUser
                            ? AppDimensions.radiusSM
                            : AppDimensions.radiusLG,
                      ),
                    ),
                  ),
                  child: _BubbleContent(
                    message: message,
                    textColor: textColor,
                    isPlaying: isPlaying,
                    onPlayTap: onPlayTap,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.createdAt.displayTime,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: AppDimensions.spaceSM),
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.message,
    required this.textColor,
    required this.isPlaying,
    this.onPlayTap,
  });

  final ChatMessageEntity message;
  final Color textColor;
  final bool isPlaying;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    // User voice message
    if (message.isAudio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: onPlayTap,
            child: Icon(
              isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
              color: textColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            isPlaying ? 'Playing…' : 'Voice message',
            style: AppTextStyles.body.copyWith(color: textColor),
          ),
        ],
      );
    }

    final bool isAssistant = !message.isFromUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Date + time header for every assistant message
        if (isAssistant) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.access_time_rounded,
                  size: 11, color: textColor.withOpacity(0.5)),
              const SizedBox(width: 3),
              Text(
                message.createdAt.displayDateTime,
                style: AppTextStyles.label.copyWith(
                  color: textColor.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSM),
        ],

        // Reply text
        Text(
          message.text,
          style: AppTextStyles.body.copyWith(color: textColor),
        ),

        // Transaction cards (recorded transactions)
        if (message.transactions.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceMD),
          ...message.transactions.map(
            (t) => _TransactionCard(transaction: t),
          ),
        ],

        // Draft summary card (pre-confirmation)
        if (isAssistant &&
            message.transactionDraft != null) ...<Widget>[
          BlocBuilder<BusinessAssistantBloc, BusinessAssistantState>(
            buildWhen: (prev, curr) =>
                prev.pendingTransaction != curr.pendingTransaction,
            builder: (ctx, state) {
              final pending = state.pendingTransaction;
              if (pending == null) return const SizedBox.shrink();
              // Collect inventory product names for autocomplete
              final inventoryState = ctx.watch<InventoryBloc>().state;
              final List<InventoryItemEntity> inventoryItems = switch (inventoryState) {
                InventorySuccess(items: final items) => items,
                InventoryActionInProgress(items: final items) => items,
                _ => const <InventoryItemEntity>[],
              };
              return TransactionDraftCard(
                draft: message.transactionDraft!,
                pendingTransaction: pending,
                inventoryItems: inventoryItems,
              );
            },
          ),
        ],

        // Confidence badge
        if (isAssistant && message.confidence != null) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSM),
          _ConfidenceBadge(level: message.confidence!),
        ],

        // MuRIL intent chip
        if (isAssistant &&
            message.murilAnalysis != null &&
            message.murilAnalysis!.intent != 'UNCLEAR') ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSM),
          _MurilIntentChip(
            intent: message.murilAnalysis!.intent,
            confidence: message.murilAnalysis!.intentConfidence,
          ),
        ],

        // MuRIL NER entity chips
        if (isAssistant &&
            message.murilAnalysis != null &&
            message.murilAnalysis!.highConfidenceEntities().isNotEmpty) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceXS),
          _MurilEntitiesRow(
            entities: message.murilAnalysis!.highConfidenceEntities(),
          ),
        ],

        // Clarification needed
        if (isAssistant &&
            message.clarificationNeeded != null &&
            message.clarificationNeeded!.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSM),
          _ClarificationBanner(text: message.clarificationNeeded!),
        ],

        // TTS listen button
        if (message.audioUrl != null) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSM),
          GestureDetector(
            onTap: onPlayTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_outlined,
                  color: textColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  isPlaying ? 'Stop' : 'Listen',
                  style: AppTextStyles.label.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Transaction card ──────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final ChatTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceSM,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMD),
                topRight: Radius.circular(AppDimensions.radiusMD),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(_typeIcon(transaction.type),
                    size: 16, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spaceXS),
                Text(
                  transaction.type.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                _StatusChip(status: transaction.status),
              ],
            ),
          ),

          // Details grid
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Column(
              children: <Widget>[
                if (transaction.customerName != null)
                  _DetailRow(
                    label: 'Customer',
                    value: transaction.customerName!,
                  ),
                if (transaction.totalAmount != null)
                  _DetailRow(
                    label: 'Total',
                    value: _fmt(transaction.totalAmount!),
                    valueColor: AppColors.textPrimary,
                    bold: true,
                  ),
                if (transaction.amountPaid != null)
                  _DetailRow(
                    label: 'Paid',
                    value: _fmt(transaction.amountPaid!),
                    valueColor: AppColors.success,
                  ),
                if (transaction.pendingAmount != null &&
                    transaction.pendingAmount! > 0)
                  _DetailRow(
                    label: 'Pending',
                    value: _fmt(transaction.pendingAmount!),
                    valueColor: AppColors.error,
                  ),
                if (transaction.customerTotalPending != null &&
                    transaction.customerTotalPending! > 0)
                  _DetailRow(
                    label: 'Total Pending',
                    value: _fmt(transaction.customerTotalPending!),
                    valueColor: AppColors.warning,
                  ),
                if (transaction.isCredit)
                  _DetailRow(
                    label: 'Type',
                    value: 'Credit',
                    valueColor: AppColors.info,
                  ),
              ],
            ),
          ),

          // Items
          if (transaction.items.isNotEmpty) ...<Widget>[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ITEMS',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  ...transaction.items.map((item) => _ItemRow(item: item)),
                ],
              ),
            ),
          ],

          // Note
          if (transaction.note != null && transaction.note!.isNotEmpty) ...<Widget>[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.notes_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Expanded(
                    child: Text(
                      transaction.note!,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _typeIcon(String type) {
    return switch (type.toLowerCase()) {
      'purchase' => Icons.shopping_cart_outlined,
      'sale' => Icons.sell_outlined,
      'payment' => Icons.payments_outlined,
      'expense' => Icons.money_off_outlined,
      _ => Icons.receipt_outlined,
    };
  }

  static String _fmt(double amount) {
    final int rounded = amount.round();
    return '₹${rounded == amount ? rounded.toString() : amount.toStringAsFixed(2)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (status.toLowerCase()) {
      'recorded' || 'completed' => (
          const Color(0xFFDCF7E7),
          AppColors.success,
          Icons.check_circle_outline,
        ),
      'pending' => (
          const Color(0xFFFFF3E0),
          AppColors.warning,
          Icons.pending_outlined,
        ),
      'failed' => (
          const Color(0xFFFFEBEE),
          AppColors.error,
          Icons.cancel_outlined,
        ),
      _ => (
          AppColors.surfaceAlt,
          AppColors.textSecondary,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: AppTextStyles.label.copyWith(color: fg, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.label.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final ChatTransactionItemEntity item;

  @override
  Widget build(BuildContext context) {
    final String qty = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toString();
    final String unit = item.unit != null ? ' ${item.unit}' : '';
    final String rate = item.ratePerUnit == item.ratePerUnit.roundToDouble()
        ? item.ratePerUnit.toInt().toString()
        : item.ratePerUnit.toStringAsFixed(2);
    final String sub = item.subtotal == item.subtotal.roundToDouble()
        ? item.subtotal.toInt().toString()
        : item.subtotal.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          const Icon(Icons.circle, size: 5, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Text(
            '$qty$unit × ₹$rate = ₹$sub',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Confidence badge ──────────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (level.toLowerCase()) {
      'high' => (AppColors.success, 'High confidence'),
      'medium' => (AppColors.warning, 'Medium confidence'),
      'low' => (AppColors.error, 'Low confidence'),
      _ => (AppColors.textSecondary, level),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.circle, size: 7, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Clarification banner ──────────────────────────────────────────────────────

class _ClarificationBanner extends StatelessWidget {
  const _ClarificationBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: AppColors.warning),
          const SizedBox(width: AppDimensions.spaceXS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.label.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.smart_toy_outlined,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceMD,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLG),
                topRight: Radius.circular(AppDimensions.radiusLG),
                bottomLeft: Radius.circular(AppDimensions.radiusSM),
                bottomRight: Radius.circular(AppDimensions.radiusLG),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _Dot(),
                SizedBox(width: 4),
                _Dot(),
                SizedBox(width: 4),
                _Dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Customer selection ────────────────────────────────────────────────────────

class _CustomerSelectionWidget extends StatelessWidget {
  const _CustomerSelectionWidget({
    required this.candidates,
    required this.onSelected,
    required this.onOtherCustomer,
  });

  final List<ChatCustomerCandidate> candidates;
  final void Function(ChatCustomerCandidate candidate) onSelected;
  final VoidCallback onOtherCustomer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 48,
        right: AppDimensions.pagePadding,
        bottom: AppDimensions.spaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
            child: Row(
              children: <Widget>[
                const Icon(Icons.touch_app_outlined,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: AppDimensions.spaceXS),
                Text(
                  'Sahi customer select karo:',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...candidates.map(
            (c) => _CandidateButton(
              candidate: c,
              onTap: () => onSelected(c),
            ),
          ),
          // Other customer option
          GestureDetector(
            onTap: onOtherCustomer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMD,
                vertical: AppDimensions.spaceMD,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.person_add_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    'Doosra customer (list mein nahi hai)',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateButton extends StatelessWidget {
  const _CandidateButton({required this.candidate, required this.onTap});

  final ChatCustomerCandidate candidate;
  final VoidCallback onTap;

  static String _fmtPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Phone nahi hai';
    return phone;
  }

  static String _fmtPending(double pending) {
    final int rounded = pending.round();
    return '₹${rounded == pending ? rounded.toString() : pending.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.primary.withOpacity(0.35)),
        ),
        child: Row(
          children: <Widget>[
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    candidate.name,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        _fmtPhone(candidate.phone),
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        'Baaki: ${_fmtPending(candidate.pending)}',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (candidate.similarityScore != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.auto_awesome_outlined,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          'MuRIL match: ${(candidate.similarityScore! * 100).round()}%',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Single-customer verification ──────────────────────────────────────────────

class _CustomerVerificationWidget extends StatelessWidget {
  const _CustomerVerificationWidget({
    required this.candidate,
    required this.onConfirm,
    required this.onReject,
  });

  final ChatCustomerCandidate candidate;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  static String _fmtPhone(String? phone) =>
      (phone == null || phone.isEmpty) ? 'Phone nahi hai' : phone;

  static String _fmtPending(double pending) {
    final int rounded = pending.round();
    return '₹${rounded == pending ? rounded.toString() : pending.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final String phone = _fmtPhone(candidate.phone);
    final bool hasPhone = candidate.phone != null && candidate.phone!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(
        left: 48,
        right: AppDimensions.pagePadding,
        bottom: AppDimensions.spaceMD,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMD,
                vertical: AppDimensions.spaceSM,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMD),
                  topRight: Radius.circular(AppDimensions.radiusMD),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.verified_user_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    'Confirm karo — sahi customer hai?',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Customer details
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person,
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          candidate.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(
                              hasPhone
                                  ? Icons.phone_outlined
                                  : Icons.phone_disabled_outlined,
                              size: 14,
                              color: hasPhone
                                  ? AppColors.textSecondary
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: AppTextStyles.label.copyWith(
                                color: hasPhone
                                    ? AppColors.textPrimary
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.account_balance_wallet_outlined,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Baaki: ${_fmtPending(candidate.pending)}',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instruction text
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMD,
              ),
              child: Text(
                hasPhone
                    ? 'Upar diya naam aur mobile number verify karke confirm karo.'
                    : 'Is customer ka phone number registered nahi hai.',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            const Divider(height: 1, color: AppColors.border),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceSM),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Galat customer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Haan, sahi hai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── New-customer name + phone form ────────────────────────────────────────────

class _PhoneInputWidget extends StatefulWidget {
  const _PhoneInputWidget({
    required this.prefillName,
    required this.onSubmit,
  });

  /// Pre-filled from the AI-parsed customer name (may be empty for "Other Customer").
  final String prefillName;

  /// Called with (name, phone) — both guaranteed non-empty.
  final void Function(String name, String phone) onSubmit;

  @override
  State<_PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<_PhoneInputWidget> {
  late final TextEditingController _nameController;
  final TextEditingController _phoneController = TextEditingController();
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Naam zaroori hai' : null;
      _phoneError = phone.isEmpty ? 'Mobile number zaroori hai' : null;
    });
    if (name.isEmpty || phone.isEmpty) return;
    widget.onSubmit(name, phone);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 48,
        right: AppDimensions.pagePadding,
        bottom: AppDimensions.spaceMD,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.primary.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMD,
                vertical: AppDimensions.spaceSM,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMD),
                  topRight: Radius.circular(AppDimensions.radiusMD),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.person_add_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    'Customer ki details bhariye',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name field
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Customer ka naam *',
                      hintText: 'Naam likhiye',
                      errorText: _nameError,
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMD,
                        vertical: AppDimensions.spaceSM,
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // Phone field
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Mobile number *',
                      hintText: '10-digit number',
                      errorText: _phoneError,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMD,
                        vertical: AppDimensions.spaceSM,
                      ),
                      isDense: true,
                    ),
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Confirm karein'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceSM,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MuRIL: Language chip (AppBar) ─────────────────────────────────────────────

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.language});

  final String language;

  static String _label(String lang) => switch (lang) {
        'hi-Deva' => 'हिंदी',
        'hi-Latn' => 'Hinglish',
        'en' => 'English',
        _ => lang,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.language_outlined,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            _label(language),
            style: AppTextStyles.label
                .copyWith(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── MuRIL: Intent chip (inside bubble) ────────────────────────────────────────

class _MurilIntentChip extends StatelessWidget {
  const _MurilIntentChip({
    required this.intent,
    required this.confidence,
  });

  final String intent;
  final double confidence;

  static String _label(String intent) => switch (intent) {
        'ADD_SALE' => 'Sale',
        'ADD_PAYMENT' => 'Payment',
        'VIEW_BALANCE' => 'Balance check',
        'ADD_EXPENSE' => 'Expense',
        'SEND_REMINDER' => 'Reminder',
        'VIEW_TRANSACTIONS' => 'Transactions',
        'ADD_CUSTOMER' => 'New customer',
        'CANCEL' => 'Cancel',
        _ => intent,
      };

  static IconData _icon(String intent) => switch (intent) {
        'ADD_SALE' => Icons.sell_outlined,
        'ADD_PAYMENT' => Icons.payments_outlined,
        'VIEW_BALANCE' => Icons.account_balance_wallet_outlined,
        'ADD_EXPENSE' => Icons.money_off_outlined,
        'SEND_REMINDER' => Icons.notifications_outlined,
        'VIEW_TRANSACTIONS' => Icons.receipt_long_outlined,
        'ADD_CUSTOMER' => Icons.person_add_outlined,
        _ => Icons.auto_awesome_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon(intent), size: 11, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            '${_label(intent)} · $pct%',
            style: AppTextStyles.label
                .copyWith(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── MuRIL: NER entity chips row (inside bubble) ────────────────────────────────

class _MurilEntitiesRow extends StatelessWidget {
  const _MurilEntitiesRow({required this.entities});

  final List<MurilEntity> entities;

  static (Color, IconData) _style(String type) => switch (type) {
        'PERSON' => (AppColors.info, Icons.person_outline),
        'AMOUNT' => (AppColors.success, Icons.currency_rupee),
        'PRODUCT' => (AppColors.warning, Icons.inventory_2_outlined),
        'DATE' => (AppColors.textSecondary, Icons.calendar_today_outlined),
        'QUANTITY' => (AppColors.textSecondary, Icons.numbers_outlined),
        _ => (AppColors.textSecondary, Icons.label_outline),
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: entities.map((entity) {
        final (color, icon) = _style(entity.type);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 3),
              Text(
                entity.value,
                style: AppTextStyles.label
                    .copyWith(color: color, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Quick reply chips ─────────────────────────────────────────────────────────

class _QuickReplyBar extends StatelessWidget {
  const _QuickReplyBar({required this.onTap});

  final void Function(String text) onTap;

  static const List<(String label, String message)> _chips = [
    ('Sale entry', 'Sale entry'),
    ('Payment received', 'Payment received'),
    ('Expense add', 'Expense add'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
        ),
        itemCount: _chips.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.spaceSM),
        itemBuilder: (context, index) {
          final (label, message) = _chips[index];
          return ActionChip(
            label: Text(label, style: AppTextStyles.label),
            backgroundColor: AppColors.primaryLight,
            side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
            shape: const StadiumBorder(),
            onPressed: () => onTap(message),
          );
        },
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isRecording,
    required this.onSend,
    required this.onMicTap,
  });

  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.spaceSM,
          AppDimensions.pagePadding,
          AppDimensions.spaceMD,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Kuch bhi poochein…',
                  hintStyle: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG,
                    vertical: AppDimensions.spaceMD,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            FloatingActionButton.small(
              heroTag: 'mic_fab',
              onPressed: onMicTap,
              backgroundColor:
                  isRecording ? Colors.red : AppColors.primaryLight,
              foregroundColor:
                  isRecording ? Colors.white : AppColors.primary,
              child: Icon(isRecording ? Icons.stop : Icons.mic),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            FloatingActionButton.small(
              heroTag: 'send_fab',
              onPressed: onSend,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

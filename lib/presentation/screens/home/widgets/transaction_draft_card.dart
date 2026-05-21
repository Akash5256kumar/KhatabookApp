import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/domain/entities/chat_transaction_entity.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/presentation/blocs/home/business_assistant_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Summary card shown before a sale transaction is confirmed.
/// Supports inline editing of quantities, rates, and amounts.
class TransactionDraftCard extends StatefulWidget {
  const TransactionDraftCard({
    super.key,
    required this.draft,
    required this.pendingTransaction,
    this.inventoryItems = const <InventoryItemEntity>[],
  });

  final TransactionDraftEntity draft;
  final Map<String, dynamic> pendingTransaction;
  /// Inventory items used for autocomplete — matches by product name AND category.
  final List<InventoryItemEntity> inventoryItems;

  @override
  State<TransactionDraftCard> createState() => _TransactionDraftCardState();
}

class _TransactionDraftCardState extends State<TransactionDraftCard> {
  late Map<String, dynamic> _tx;
  late TransactionDraftEntity _draft;
  bool _isEditing = false;

  // Edit controllers — one per item (name + qty + rate) + top-level amount_paid
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _qtyControllers;
  late List<TextEditingController> _rateControllers;
  late TextEditingController _amountPaidCtrl;

  @override
  void initState() {
    super.initState();
    _tx = Map<String, dynamic>.from(widget.pendingTransaction);
    _draft = widget.draft;
    _initControllers();
  }

  void _initControllers() {
    _nameControllers = _draft.items
        .map((i) => TextEditingController(text: i.name))
        .toList();
    _qtyControllers = _draft.items
        .map((i) => TextEditingController(text: i.quantity?.toString() ?? ''))
        .toList();
    _rateControllers = _draft.items
        .map((i) => TextEditingController(text: i.ratePerUnit?.toStringAsFixed(0) ?? ''))
        .toList();
    _amountPaidCtrl = TextEditingController(
        text: _draft.amountPaid.toStringAsFixed(0));
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _qtyControllers) {
      c.dispose();
    }
    for (final c in _rateControllers) {
      c.dispose();
    }
    _amountPaidCtrl.dispose();
    super.dispose();
  }

  void _applyEdits() {
    final List<Map<String, dynamic>> updatedItems = [];
    for (int i = 0; i < _draft.items.length; i++) {
      final item = _draft.items[i];
      final String name = _nameControllers[i].text.trim().isNotEmpty
          ? _nameControllers[i].text.trim()
          : item.name;
      final double qty = double.tryParse(_qtyControllers[i].text) ?? (item.quantity ?? 0);
      final double rate = double.tryParse(_rateControllers[i].text) ?? (item.ratePerUnit ?? 0);
      final double subtotal = qty * rate;
      // If name was edited, price is now user-provided
      final String priceSource =
          name.toLowerCase() != item.name.toLowerCase() ? 'user' : item.priceSource ?? 'user';
      updatedItems.add({
        'name': name,
        'quantity': qty,
        'unit': item.unit,
        'rate_per_unit': rate,
        'price_source': priceSource,
        'subtotal': subtotal,
      });
    }

    final double total = updatedItems.fold(0.0, (s, i) => s + (i['subtotal'] as double));
    final double paid = double.tryParse(_amountPaidCtrl.text) ?? _draft.amountPaid;
    final double pending = (total - paid).clamp(0.0, double.infinity);

    final updatedDraft = TransactionDraftEntity(
      type: _draft.type,
      customerName: _draft.customerName,
      items: updatedItems
          .map((i) => TransactionDraftItemEntity(
                name: i['name'] as String,
                quantity: (i['quantity'] as num).toDouble(),
                unit: i['unit'] as String?,
                ratePerUnit: (i['rate_per_unit'] as num).toDouble(),
                subtotal: (i['subtotal'] as num).toDouble(),
                priceSource: (i['price_source'] as String?) ?? 'user',
              ))
          .toList(),
      totalAmount: total,
      amountPaid: paid,
      pendingAmount: pending,
      isCredit: pending > 0,
      note: _draft.note,
    );

    // Update the pending_transaction dict with edited values
    _tx = {
      ..._tx,
      'items': updatedItems,
      'total_amount': total,
      'amount_paid': paid,
      'pending_amount': pending,
      'is_credit': pending > 0,
      'calculated_total': total,
    };

    setState(() {
      _draft = updatedDraft;
      _isEditing = false;
    });
  }

  void _confirm() {
    context.read<BusinessAssistantBloc>().add(
          BusinessAssistantDraftConfirmed(pendingTransaction: _tx),
        );
  }

  void _cancel() {
    context.read<BusinessAssistantBloc>().add(const BusinessAssistantDraftCancelled());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLG,
              vertical: AppDimensions.spaceMD,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLG - 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    'Transaction Summary',
                    style: AppTextStyles.title.copyWith(color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    _draft.type.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer
                if (_draft.customerName != null) ...[
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Customer',
                    value: _draft.customerName!,
                  ),
                  const Divider(height: AppDimensions.spaceXL),
                ],

                // Items
                ..._buildItemRows(),

                const Divider(height: AppDimensions.spaceXL),

                // Totals
                if (_isEditing) ...[
                  _EditRow(
                    label: 'Amount Paid (₹)',
                    controller: _amountPaidCtrl,
                  ),
                ] else ...[
                  _TotalRow(
                    label: 'Total',
                    amount: _draft.totalAmount,
                    bold: false,
                  ),
                  _TotalRow(
                    label: 'Amount Paid',
                    amount: _draft.amountPaid,
                    bold: false,
                    color: AppColors.success,
                  ),
                  if (_draft.pendingAmount > 0)
                    _TotalRow(
                      label: 'Pending (Baaki)',
                      amount: _draft.pendingAmount,
                      bold: true,
                      color: AppColors.warning,
                    ),
                ],
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spaceLG,
              0,
              AppDimensions.spaceLG,
              AppDimensions.spaceLG,
            ),
            child: _isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMD),
                      Expanded(
                        child: FilledButton(
                          onPressed: _applyEdits,
                          child: const Text('Apply Changes'),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Edit + Cancel side by side
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceSM),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceSM),
                      // Confirm full width
                      FilledButton.icon(
                        onPressed: _confirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Confirm Transaction'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemRows() {
    return List.generate(_draft.items.length, (i) {
      final item = _draft.items[i];
      if (_isEditing) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Autocomplete product name field (matches by name AND category)
              _ProductNameField(
                controller: _nameControllers[i],
                inventoryItems: widget.inventoryItems,
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              Row(
                children: [
                  Expanded(
                    child: _EditRow(
                      label: 'Qty${item.unit != null ? " (${item.unit})" : ""}',
                      controller: _qtyControllers[i],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: _EditRow(
                      label: 'Rate (₹)',
                      controller: _rateControllers[i],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: AppTextStyles.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.priceFromInventory) ...[
                        const SizedBox(width: AppDimensions.spaceXS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Auto',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: AppDimensions.spaceXS),
                        Tooltip(
                          message: 'Product not in inventory.\nTap Edit to correct the name.',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Manual',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.warning,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${item.quantity?.toStringAsFixed(item.quantity == item.quantity?.roundToDouble() ? 0 : 1) ?? '?'}'
                    '${item.unit != null ? " ${item.unit}" : ""}'
                    ' × ₹${item.ratePerUnit?.toStringAsFixed(0) ?? '?'}',
                    style: AppTextStyles.bodyMuted,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '₹${item.subtotal.toStringAsFixed(0)}',
              style: AppTextStyles.title,
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: AppDimensions.spaceSM),
        Text('$label: ', style: AppTextStyles.bodyMuted),
        Text(value, style: AppTextStyles.title),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.bold = false,
    this.color,
  });
  final String label;
  final double amount;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.title.copyWith(color: color)
        : AppTextStyles.body.copyWith(color: color ?? AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹${amount.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceSM,
            vertical: AppDimensions.spaceSM),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Autocomplete field that matches product names AND category names.
/// Typing "Rice" shows "Basmati Rice", "Brown Rice", etc. (category match).
/// Typing "Basmat" shows "Basmati Rice" (product name match + typo tolerance).
class _ProductNameField extends StatelessWidget {
  const _ProductNameField({
    required this.controller,
    required this.inventoryItems,
  });

  final TextEditingController controller;
  final List<InventoryItemEntity> inventoryItems;

  bool _matches(InventoryItemEntity item, String q) {
    if (item.productName.toLowerCase().contains(q)) return true;
    if (item.category != null && item.category!.toLowerCase().contains(q)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<InventoryItemEntity>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable<InventoryItemEntity>.empty();
        final String q = value.text.toLowerCase();
        return inventoryItems.where((item) => _matches(item, q));
      },
      displayStringForOption: (item) => item.productName,
      onSelected: (InventoryItemEntity item) {
        controller.text = item.productName;
      },
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        fieldController.text = controller.text;
        fieldController.addListener(() => controller.text = fieldController.text);
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Product Name',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceSM,
                vertical: AppDimensions.spaceSM),
            border: const OutlineInputBorder(),
            suffixIcon: inventoryItems.isEmpty
                ? null
                : const Icon(Icons.arrow_drop_down, size: 18),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final InventoryItemEntity item = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMD,
                          vertical: AppDimensions.spaceSM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(item.productName, style: AppTextStyles.body),
                          if (item.category != null)
                            Text(
                              item.category!,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

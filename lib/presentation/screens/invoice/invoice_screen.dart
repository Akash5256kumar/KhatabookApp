import 'dart:io';
import 'dart:typed_data';

import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/date_extension.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/core/utils/invoice_pdf.dart';
import 'package:apna_business_app/domain/entities/invoice_entity.dart';
import 'package:apna_business_app/presentation/blocs/invoice/invoice_bloc.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Full-screen invoice view with line items, totals, PDF download and share.
class InvoiceScreen extends StatefulWidget {
  /// Creates the screen.
  const InvoiceScreen({required this.invoiceId, super.key});

  /// Invoice identifier passed from the router.
  final String invoiceId;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _isProcessing = false;

  Future<Uint8List?> _generatePdf(InvoiceEntity invoice) async {
    try {
      return await buildInvoicePdf(invoice);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate PDF. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _downloadPdf(InvoiceEntity invoice) async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? bytes = await _generatePdf(invoice);
      if (bytes == null) return;

      final Directory dir = await getApplicationDocumentsDirectory();
      final String fileName = 'Invoice_${invoice.invoiceNumber}.pdf';
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareViaWhatsApp(InvoiceEntity invoice) async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? bytes = await _generatePdf(invoice);
      if (bytes == null) return;

      final String fileName = 'Invoice_${invoice.invoiceNumber}.pdf';
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
        subject: 'Invoice ${invoice.invoiceNumber} from ${invoice.customerName}',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        centerTitle: false,
      ),
      body: Stack(
        children: <Widget>[
          BlocConsumer<InvoiceBloc, InvoiceState>(
            listener: (BuildContext context, InvoiceState state) {
              if (state is InvoiceFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              }
            },
            builder: (BuildContext context, InvoiceState state) {
              return switch (state) {
                InvoiceLoading() =>
                  const Center(child: CircularProgressIndicator()),
                InvoiceSuccess() => _InvoiceContent(
                    invoice: state.invoice,
                    onDownload: () => _downloadPdf(state.invoice),
                    onWhatsApp: () => _shareViaWhatsApp(state.invoice),
                  ),
                InvoiceEmpty() => const EmptyStateView(
                    title: 'Invoice not found',
                    message:
                        'This transaction does not exist or you do not have access to it.',
                  ),
                InvoiceFailure() => BrandedErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<InvoiceBloc>()
                        .add(InvoiceRetried(id: widget.invoiceId)),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generating PDF…'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceContent extends StatelessWidget {
  const _InvoiceContent({
    required this.invoice,
    required this.onDownload,
    required this.onWhatsApp,
  });

  final InvoiceEntity invoice;
  final VoidCallback onDownload;
  final VoidCallback onWhatsApp;

  Color _statusColor() {
    return switch (invoice.status) {
      InvoiceStatus.paid => AppColors.sale,
      InvoiceStatus.partiallyPaid => AppColors.payment,
      InvoiceStatus.unpaid => AppColors.expense,
    };
  }

  String _statusLabel() {
    return switch (invoice.status) {
      InvoiceStatus.paid => 'Paid',
      InvoiceStatus.partiallyPaid => 'Partially Paid',
      InvoiceStatus.unpaid => 'Unpaid',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header card ─────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            invoice.invoiceNumber,
                            style: AppTextStyles.headline,
                          ),
                          const SizedBox(height: AppDimensions.spaceXXS),
                          Text(
                            'Created: ${invoice.createdAt.displayDate}',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMD,
                          vertical: AppDimensions.spaceSM,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withAlpha(25),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: AppTextStyles.label.copyWith(
                            color: _statusColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppDimensions.space3XL),
                  const Text('Bill To', style: AppTextStyles.bodyMuted),
                  const SizedBox(height: AppDimensions.spaceXXS),
                  Text(
                    invoice.customerName,
                    style: AppTextStyles.title,
                  ),
                  if (invoice.customerPhone.isNotEmpty)
                    Text(
                      invoice.customerPhone,
                      style: AppTextStyles.body,
                    ),
                  if (invoice.dueDate != null) ...<Widget>[
                    const SizedBox(height: AppDimensions.spaceMD),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.expense,
                        ),
                        const SizedBox(width: AppDimensions.spaceXXS),
                        Text(
                          'Due: ${invoice.dueDate!.displayDate}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // ── Line items ───────────────────────────────────────────────────
          if (invoice.items.isNotEmpty) ...<Widget>[
            const Text('Items', style: AppTextStyles.title),
            const SizedBox(height: AppDimensions.spaceMD),
            Card(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLG,
                      vertical: AppDimensions.spaceMD,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Text('Item', style: AppTextStyles.label),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Qty',
                            style: AppTextStyles.label,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Rate',
                            style: AppTextStyles.label,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...invoice.items.asMap().entries.map(
                    (MapEntry<int, InvoiceItemEntity> entry) {
                      final bool isLast =
                          entry.key == invoice.items.length - 1;
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceLG,
                              vertical: AppDimensions.spaceMD,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    entry.value.name,
                                    style: AppTextStyles.body,
                                    maxLines: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${entry.value.quantity}',
                                    style: AppTextStyles.body,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${entry.value.rate.toStringAsFixed(0)}',
                                    style: AppTextStyles.body,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
          ],

          // ── Payment summary card ─────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Column(
                children: <Widget>[
                  _TotalRow(
                    label: 'Total Amount',
                    amount: invoice.grandTotal,
                    isTotal: true,
                  ),
                  const Divider(height: AppDimensions.spaceXL),
                  _TotalRow(
                    label: 'Amount Paid',
                    amount: invoice.amountPaid,
                    color: AppColors.success,
                  ),
                  if (invoice.pendingAmount > 0) ...<Widget>[
                    const SizedBox(height: AppDimensions.spaceXS),
                    _TotalRow(
                      label: 'Remaining Pending',
                      amount: invoice.pendingAmount,
                      color: AppColors.warning,
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXXL),

          // ── Actions ──────────────────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceMD),
                  ),
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share on WhatsApp'),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceMD),
                  ),
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space4XL),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isBold = false,
    this.color,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = isTotal
        ? AppTextStyles.title
        : isBold
            ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: color)
            : AppTextStyles.body.copyWith(color: color);
    final TextStyle valueStyle = isTotal
        ? AppTextStyles.headline.copyWith(color: AppColors.primary)
        : isBold
            ? AppTextStyles.title.copyWith(color: color)
            : AppTextStyles.body.copyWith(color: color);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: labelStyle),
        Text(amount.toInr, style: valueStyle),
      ],
    );
  }
}

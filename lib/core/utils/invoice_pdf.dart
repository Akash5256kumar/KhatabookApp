import 'dart:typed_data';

import 'package:apna_business_app/domain/entities/invoice_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds a PDF document for [invoice] and returns the raw bytes.
///
/// Uses Noto Sans so the ₹ (U+20B9) glyph renders correctly — the
/// built-in Helvetica/Times fonts have no glyph for it.
Future<Uint8List> buildInvoicePdf(InvoiceEntity invoice) async {
  final pw.Font regular = await PdfGoogleFonts.notoSansRegular();
  final pw.Font bold = await PdfGoogleFonts.notoSansBold();

  final pw.Document doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      build: (pw.Context ctx) => _buildBody(invoice),
    ),
  );

  return doc.save();
}

pw.Widget _buildBody(InvoiceEntity invoice) {
  final bool hasPending = invoice.pendingAmount > 0;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      _header(invoice),
      pw.SizedBox(height: 20),
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 12),
      _billTo(invoice),
      pw.SizedBox(height: 20),
      _itemsTable(invoice),
      pw.SizedBox(height: 16),
      pw.Divider(color: PdfColors.grey300),
      pw.SizedBox(height: 8),
      _totalRow(invoice),
      if (hasPending) ...<pw.Widget>[
        pw.SizedBox(height: 16),
        _pendingBadge(invoice.pendingAmount),
      ],
    ],
  );
}

pw.Widget _header(InvoiceEntity invoice) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Container(
        width: 48,
        height: 48,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#E8F5E9'),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          invoice.customerName.isNotEmpty
              ? invoice.customerName[0].toUpperCase()
              : 'I',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1A7A40'),
          ),
        ),
      ),
      pw.SizedBox(width: 12),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            invoice.customerName,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            invoice.invoiceNumber,
            style: const pw.TextStyle(
              fontSize: 13,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Date: ${_formatDate(invoice.createdAt)}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _billTo(InvoiceEntity invoice) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(
        'Bill To:',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        invoice.customerName,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}

pw.Widget _itemsTable(InvoiceEntity invoice) {
  return pw.Table(
    columnWidths: const <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(5),
      1: pw.FlexColumnWidth(2),
      2: pw.FlexColumnWidth(2),
    },
    children: <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: <pw.Widget>[
          _cell('Item', isHeader: true),
          _cell('Qty', isHeader: true, align: pw.Alignment.center),
          _cell('Rate', isHeader: true, align: pw.Alignment.centerRight),
        ],
      ),
      ...invoice.items.map(
        (InvoiceItemEntity item) => pw.TableRow(
          children: <pw.Widget>[
            _cell(item.name),
            _cell('${item.quantity}', align: pw.Alignment.center),
            _cell('₹${item.rate.toStringAsFixed(0)}',
                align: pw.Alignment.centerRight),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _totalRow(InvoiceEntity invoice) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: <pw.Widget>[
      pw.Text(
        'Total Amount',
        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        '₹${invoice.grandTotal.toStringAsFixed(0)}',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}

pw.Widget _pendingBadge(double amount) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#FFF3E0'),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      children: <pw.Widget>[
        pw.Text(
          'Payment Pending: ',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#E65100'),
          ),
        ),
        pw.Text(
          '₹${amount.toStringAsFixed(0)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#E65100'),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _cell(
  String text, {
  bool isHeader = false,
  pw.Alignment align = pw.Alignment.centerLeft,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Align(
      alignment: align,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    ),
  );
}

String _formatDate(DateTime d) {
  const List<String> months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

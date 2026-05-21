import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/models/detail_model.dart';
import 'package:apna_business_app/domain/entities/invoice_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:dio/dio.dart';

/// Remote datasource for transaction detail.
class DetailRemoteDataSource {
  /// Creates the remote datasource.
  DetailRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Loads a detail record.
  Future<DetailModel> fetchDetail(String id) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/api/v1/home/transactions/$id',
      );
      final data = response.data ?? <String, dynamic>{};
      final String rawType = (data['type'] as String? ?? 'sale').toLowerCase();
      final bool isCredit = data['is_credit'] as bool? ?? false;
      return DetailModel(
        id: data['id']?.toString() ?? id,
        title: data['title'] as String? ?? 'Transaction',
        subtitle: data['subtitle'] as String? ?? '',
        imageUrl: data['image_url'] as String? ?? '',
        description: data['description'] as String? ?? '',
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
            DateTime.now(),
        type: (rawType == 'sale' && isCredit)
            ? TransactionType.credit
            : _mapTransactionType(rawType),
        highlights: (data['highlights'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic item) => item.toString())
            .toList(growable: false),
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Fetches a transaction and maps it to an [InvoiceEntity].
  Future<InvoiceEntity> fetchInvoice(String id) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/api/v1/home/transactions/$id',
      );
      final data = response.data ?? <String, dynamic>{};

      final double amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final bool isCredit = data['is_credit'] as bool? ?? false;
      final String type = (data['type'] as String? ?? 'sale').toLowerCase();

      // amount_paid is the authoritative source; fall back to full payment if absent.
      final double amountPaid = (data['amount_paid'] as num?)?.toDouble() ??
          (isCredit ? 0.0 : amount);
      // Compute transaction-level pending from amount_paid, not customer balance.
      final double pending = (amount - amountPaid).clamp(0.0, double.infinity);

      final InvoiceStatus status = _invoiceStatus(
        type: type,
        amount: amount,
        pendingAmount: pending,
        isCredit: isCredit,
      );

      final List<dynamic> rawItems =
          data['items'] as List<dynamic>? ?? <dynamic>[];
      final List<InvoiceItemEntity> items = rawItems
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => InvoiceItemEntity(
                name: item['name'] as String? ?? '',
                quantity: (item['quantity'] as num?)?.toDouble() ?? 1.0,
                rate: (item['rate'] as num?)?.toDouble() ?? 0,
              ))
          .where((InvoiceItemEntity i) => i.name.isNotEmpty)
          .toList(growable: false);

      return InvoiceEntity(
        id: data['id']?.toString() ?? id,
        invoiceNumber: 'INV-${data['id'] ?? id}',
        customerName: (data['customer_name'] as String?)?.trim().isEmpty ?? true
            ? (data['subtitle'] as String? ?? 'Customer')
            : data['customer_name'] as String,
        customerPhone: data['customer_phone'] as String? ?? '',
        items: items,
        totalAmount: amount,
        amountPaid: amountPaid,
        pendingAmount: pending,
        status: status,
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ??
            DateTime.now(),
        dueDate: null,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  InvoiceStatus _invoiceStatus({
    required String type,
    required double amount,
    required double pendingAmount,
    required bool isCredit,
  }) {
    if (type == 'payment') return InvoiceStatus.paid;
    if (!isCredit) return InvoiceStatus.paid;
    if (pendingAmount <= 0) return InvoiceStatus.paid;
    if (pendingAmount < amount) return InvoiceStatus.partiallyPaid;
    return InvoiceStatus.unpaid;
  }

  TransactionType _mapTransactionType(String rawType) {
    return switch (rawType) {
      'sale' => TransactionType.sale,
      'payment' => TransactionType.payment,
      'purchase' => TransactionType.expense,
      'expense' => TransactionType.expense,
      _ => TransactionType.sale,
    };
  }

}

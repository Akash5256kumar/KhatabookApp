import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/core/network/dio_client.dart';
import 'package:apna_business_app/data/models/customer_model.dart';
import 'package:apna_business_app/data/models/home_feed_model.dart';
import 'package:apna_business_app/data/models/transaction_model.dart';
import 'package:apna_business_app/data/models/user_model.dart';
import 'package:apna_business_app/domain/entities/home_user_info.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';

typedef TransactionPageModel = ({
  List<TransactionModel> items,
  int page,
  bool hasMore,
});

typedef CustomerPageModel = ({
  List<CustomerModel> items,
  int page,
  bool hasMore,
});

/// Remote datasource for home dashboard data.
class HomeRemoteDataSource {
  /// Creates the remote datasource.
  HomeRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Fetches the full home dashboard from /api/v1/home/.
  ///
  /// Returns a tuple of [HomeFeedModel] (stats + recent transactions) and
  /// [HomeUserInfo] (user, business, top customer).
  Future<(HomeFeedModel, HomeUserInfo)> fetchDashboard({
    required int page,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/api/v1/home/',
    );
    final data = response.data!;

    // ── User + business info ─────────────────────────────────────────────
    final userMap =
        data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final businessMap =
        userMap['business'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final topMap = data['top_customer'] as Map<String, dynamic>?;

    final userInfo = HomeUserInfo(
      fullName: userMap['full_name'] as String? ?? '',
      businessName: businessMap['name'] as String? ?? '',
      businessLocation: businessMap['location'] as String? ?? '',
      unreadNotifications: userMap['unread_notifications'] as int? ?? 0,
      topCustomerId: topMap?['id']?.toString(),
      topCustomerName: topMap?['name'] as String?,
      topCustomerPending: (topMap?['pending'] as num?)?.toDouble(),
    );

    // ── Stats → metrics ──────────────────────────────────────────────────
    final statsMap =
        data['stats'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final metrics = <SummaryMetricModel>[
      SummaryMetricModel(
        title: 'Today’s sales ',
        amount: (statsMap['today_sales'] as num?)?.toDouble() ?? 0,
        helperText: 'Today',
      ),
      SummaryMetricModel(
        title: 'Today’s Received ',
        amount: (statsMap['today_received'] as num?)?.toDouble() ?? 0,
        helperText: 'Today',
      ),
      SummaryMetricModel(
        title: 'Pending Amount',
        amount: (statsMap['total_pending'] as num?)?.toDouble() ?? 0,
        helperText: 'All customers',
      ),
      SummaryMetricModel(
        title: 'Today’s expenses',
        amount: (statsMap['today_expenses'] as num?)?.toDouble() ?? 0,
        helperText: 'Today',
      ),
    ];

    // ── Recent transactions ──────────────────────────────────────────────
    final rawTxns =
        data['recent_transactions'] as List<dynamic>? ?? <dynamic>[];
    final feedItems = rawTxns.map((dynamic t) {
      final txn = t as Map<String, dynamic>;
      final typeStr = (txn['type'] as String? ?? 'sale').toLowerCase();
      final bool isCredit = txn['is_credit'] as bool? ?? false;
      final TransactionType type = (typeStr == 'sale' && isCredit)
          ? TransactionType.credit
          : _mapAppTransactionType(typeStr);
      return TransactionModel(
        id: txn['id'].toString(),
        customerName: txn['customer_name'] as String? ?? '',
        title: _titleForType(typeStr),
        subtitle: isCredit ? 'Credit' : 'Cash',
        imageUrl: '',
        amount: (txn['amount'] as num?)?.toDouble() ?? 0,
        createdAt:
            DateTime.tryParse(txn['date'] as String? ?? '') ?? DateTime.now(),
        type: type,
        isPositive: type != TransactionType.expense,
      );
    }).toList(growable: false);

    final feedModel = HomeFeedModel(
      metrics: metrics,
      feedItems: feedItems,
      page: page,
      hasMore: false,
    );

    return (feedModel, userInfo);
  }

  /// Fetches paginated transactions from the dedicated endpoint.
  Future<TransactionPageModel> fetchTransactions({required int page}) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/api/v1/home/transactions',
      queryParameters: <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final items = data['items'] as List<dynamic>? ?? <dynamic>[];
    return (
      items: items
          .map(
            (dynamic item) =>
                _transactionModelFromApi(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      page: data['page'] as int? ?? page,
      hasMore: data['has_more'] as bool? ?? false,
    );
  }

  /// Fetches paginated customers from /api/v1/customers/.
  Future<CustomerPageModel> fetchCustomers({required int page}) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/api/v1/customers/',
      queryParameters: <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final items = data['items'] as List<dynamic>? ?? <dynamic>[];
    return (
      items: items
          .map(
            (dynamic item) =>
                _customerModelFromApi(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      page: data['page'] as int? ?? page,
      hasMore: data['has_more'] as bool? ?? false,
    );
  }

  /// Fetches paginated transactions for a specific customer.
  Future<List<TransactionModel>> fetchCustomerTransactions({
    required String customerId,
    required int page,
  }) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/api/v1/customers/$customerId/transactions',
      queryParameters: <String, dynamic>{
        'page': page,
        'page_size': AppConstants.pageSize,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final items = data['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .map(
          (dynamic item) => _customerTxnFromApi(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  /// Fetches the current user profile (mock).
  Future<UserModel> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return UserModel.fromJson(const <String, Object?>{
      'id': 'user-001',
      'name': 'Sharma Ji',
      'email': 'sharma@apna.business',
      'avatarUrl': '',
    });
  }

  static String _titleForType(String type) => switch (type.toLowerCase()) {
        'sale' => 'Sale',
        'payment' => 'Payment Received',
        'purchase' => 'Purchase',
        'expense' => 'Expense',
        _ => 'Transaction',
      };

  CustomerModel _customerModelFromApi(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      avatarUrl: null,
      totalSale: (json['total_sale'] as num?)?.toDouble() ?? 0.0,
      totalReceived: (json['total_received'] as num?)?.toDouble() ?? 0.0,
    );
  }

  TransactionModel _customerTxnFromApi(Map<String, dynamic> json) {
    final String rawType = (json['type'] as String? ?? 'sale').toLowerCase();
    final bool isCredit = json['is_credit'] as bool? ?? false;
    final TransactionType type = (rawType == 'sale' && isCredit)
        ? TransactionType.credit
        : _mapAppTransactionType(rawType);
    final String? note = json['note'] as String?;
    return TransactionModel(
      id: json['id'].toString(),
      customerName: '',
      title: _titleForType(rawType),
      subtitle: (note != null && note.trim().isNotEmpty)
          ? note.trim()
          : _subtitleForApiTransaction(
              rawType: rawType,
              note: note,
              isCredit: isCredit,
            ),
      imageUrl: '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      type: type,
      isPositive: type != TransactionType.expense,
    );
  }

  TransactionModel _transactionModelFromApi(Map<String, dynamic> json) {
    final String rawType = (json['type'] as String? ?? 'sale').toLowerCase();
    final bool isCredit = json['is_credit'] as bool? ?? false;
    final TransactionType type = (rawType == 'sale' && isCredit)
        ? TransactionType.credit
        : _mapAppTransactionType(rawType);
    final String subtitle = _subtitleForApiTransaction(
      rawType: rawType,
      note: json['note'] as String?,
      isCredit: isCredit,
    );
    return TransactionModel(
      id: json['id'].toString(),
      customerName: json['customer_name'] as String? ?? '',
      title: _titleForType(rawType),
      subtitle: subtitle,
      imageUrl: '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      type: type,
      isPositive: rawType == 'payment' || rawType == 'sale',
    );
  }

  String _subtitleForApiTransaction({
    required String rawType,
    required String? note,
    required bool isCredit,
  }) {
    if (note != null && note.trim().isNotEmpty) return note.trim();
    return switch (rawType) {
      'sale' => isCredit ? 'Credit sale' : 'Cash sale',
      'payment' => 'Payment received',
      'purchase' => 'Stock purchase',
      'expense' => 'Business expense',
      _ => 'Transaction',
    };
  }

  TransactionType _mapAppTransactionType(String rawType) {
    return switch (rawType) {
      'sale' => TransactionType.sale,
      'payment' => TransactionType.payment,
      'purchase' => TransactionType.expense,
      'expense' => TransactionType.expense,
      _ => TransactionType.sale,
    };
  }
}

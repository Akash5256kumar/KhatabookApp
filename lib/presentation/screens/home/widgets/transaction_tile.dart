import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable transaction tile matching the card-style Figma design.
class TransactionTile extends StatelessWidget {
  /// Creates a transaction tile.
  const TransactionTile({
    required this.transaction,
    super.key,
  });

  /// Transaction payload.
  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '${RouteNames.invoice}/${transaction.id}',
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
          vertical: AppDimensions.spaceXS,
        ),
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _TransactionTypeIcon(type: transaction.type),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (transaction.customerName.trim().isNotEmpty) ...<Widget>[
                    Text(
                      transaction.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF18233A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceXXS),
                  ],
                  Text(
                    _typeLabel(transaction.type),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF5C697D),
                    ),
                  ),
                  if (transaction.subtitle.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Text(
                      transaction.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5C697D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _formattedAmount(transaction),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _amountColor(transaction.type),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXXS),
                Text(
                  _shortDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7D889B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTypeIcon extends StatelessWidget {
  const _TransactionTypeIcon({required this.type});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color iconColor, Color bgColor) = switch (type) {
      TransactionType.sale => (
          Icons.trending_up_rounded,
          const Color(0xFF10A943),
          const Color(0xFFE8F8ED),
        ),
      TransactionType.payment => (
          Icons.arrow_circle_down_outlined,
          const Color(0xFF2463F2),
          const Color(0xFFE3EDFF),
        ),
      TransactionType.credit => (
          Icons.access_time_rounded,
          AppColors.warning,
          const Color(0xFFFFF2E2),
        ),
      TransactionType.expense => (
          Icons.trending_down_rounded,
          const Color(0xFFE32121),
          const Color(0xFFFFE9E9),
        ),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 24),
    );
  }
}

String _typeLabel(TransactionType type) => switch (type) {
      TransactionType.sale => 'Sale',
      TransactionType.payment => 'Payment Received',
      TransactionType.credit => 'Pending Amount',
      TransactionType.expense => 'Expense',
    };

String _formattedAmount(TransactionEntity t) {
  final String prefix = switch (t.type) {
    TransactionType.payment => '+',
    TransactionType.expense => '-',
    TransactionType.credit => '',
    TransactionType.sale => '',
  };
  return '$prefix${t.amount.toInr}';
}

Color _amountColor(TransactionType type) => switch (type) {
      TransactionType.sale => const Color(0xFF18233A),
      TransactionType.payment => AppColors.primary,
      TransactionType.credit => AppColors.warning,
      TransactionType.expense => AppColors.expense,
    };

String _shortDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/date_extension.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/detail_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/presentation/blocs/detail/detail_bloc.dart';
import 'package:apna_business_app/presentation/screens/detail/widgets/detail_loading_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detail screen for a transaction or entity.
class DetailScreen extends StatelessWidget {
  /// Creates the detail screen.
  const DetailScreen({
    required this.itemId,
    required this.heroTag,
    super.key,
  });

  /// Selected entity id.
  final String itemId;

  /// Hero tag from the previous screen.
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DetailBloc, DetailState>(
        builder: (BuildContext context, DetailState state) {
          return switch (state) {
            DetailLoading() => const DetailLoadingView(),
            DetailFailure() => BrandedErrorView(
                message: state.message,
                onRetry: () => context.read<DetailBloc>().add(
                      DetailRetried(id: itemId),
                    ),
              ),
            DetailEmpty() => const EmptyStateView(
                title: 'No detail available',
                message: 'This record does not have any extra information yet.',
              ),
            DetailSuccess() => CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: AppDimensions.detailHeroHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(state.detail.title),
                      background: Hero(
                        tag: heroTag,
                        child: _DetailHero(detail: state.detail),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(state.detail.subtitle,
                              style: AppTextStyles.bodyMuted),
                          const SizedBox(height: AppDimensions.spaceSM),
                          Text(
                            _formattedAmount(state.detail),
                            style: AppTextStyles.display.copyWith(
                              fontSize: 28,
                              color: _amountColor(state.detail.type),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceSM),
                          Text(
                            state.detail.createdAt.displayDateTime,
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: AppDimensions.spaceXL),
                          Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppDimensions.spaceLG),
                              child: Text(
                                state.detail.description,
                                style: AppTextStyles.body,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceLG),
                          _SummaryCard(detail: state.detail),
                          const SizedBox(height: AppDimensions.spaceLG),
                          const Text('Highlights', style: AppTextStyles.title),
                          const SizedBox(height: AppDimensions.spaceSM),
                          ...state.detail.highlights.map(
                            (String item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spaceSM,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: AppDimensions.iconSM,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.spaceSM),
                                  Expanded(
                                    child:
                                        Text(item, style: AppTextStyles.body),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space4XL),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.detail});

  final DetailEntity detail;

  @override
  Widget build(BuildContext context) {
    if (detail.imageUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: detail.imageUrl,
        memCacheHeight: 720,
        memCacheWidth: 720,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _DetailHeroFallback(detail: detail),
      );
    }
    return _DetailHeroFallback(detail: detail);
  }
}

class _DetailHeroFallback extends StatelessWidget {
  const _DetailHeroFallback({required this.detail});

  final DetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            _amountColor(detail.type),
            _amountColor(detail.type).withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _typeIcon(detail.type),
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.detail});

  final DetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Transaction Summary', style: AppTextStyles.title),
            const SizedBox(height: AppDimensions.spaceMD),
            _SummaryRow(label: 'Category', value: detail.title),
            _SummaryRow(label: 'Reference', value: detail.subtitle),
            _SummaryRow(
              label: 'Recorded',
              value: detail.createdAt.displayDateTime,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(label, style: AppTextStyles.label),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

String _formattedAmount(DetailEntity detail) {
  final String prefix = detail.type == TransactionType.payment
      ? '+'
      : detail.type == TransactionType.expense
          ? '-'
          : '';
  return '$prefix${detail.amount.toInr}';
}

Color _amountColor(TransactionType type) {
  return switch (type) {
    TransactionType.sale => AppColors.sale,
    TransactionType.payment => AppColors.payment,
    TransactionType.credit => AppColors.warning,
    TransactionType.expense => AppColors.expense,
  };
}

IconData _typeIcon(TransactionType type) {
  return switch (type) {
    TransactionType.sale => Icons.trending_up_rounded,
    TransactionType.payment => Icons.payments_rounded,
    TransactionType.credit => Icons.access_time_rounded,
    TransactionType.expense => Icons.receipt_long_rounded,
  };
}

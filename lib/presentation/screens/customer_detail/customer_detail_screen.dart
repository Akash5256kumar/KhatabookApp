import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/presentation/blocs/customer/customer_detail_bloc.dart';
import 'package:apna_business_app/presentation/screens/home/widgets/transaction_tile.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Full-screen view of a customer's balance and transaction history.
class CustomerDetailScreen extends StatefulWidget {
  /// Creates the screen.
  const CustomerDetailScreen({
    required this.customer,
    super.key,
  });

  /// Customer loaded from the customers list.
  final CustomerEntity customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_maybeLoadMore);
    context
        .read<CustomerDetailBloc>()
        .add(CustomerDetailStarted(customer: widget.customer));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      context
          .read<CustomerDetailBloc>()
          .add(const CustomerDetailLoadMoreRequested());
    }
  }

  void _sendReminder(BuildContext context, CustomerEntity customer) {
    context.push(RouteNames.paymentReminder, extra: customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Transaction - coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
      body: BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
        listener: (BuildContext context, CustomerDetailState state) {
          if (state is CustomerDetailFailure) {
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
        builder: (BuildContext context, CustomerDetailState state) {
          final CustomerEntity customer =
              (state is CustomerDetailSuccess ? state.customer : null) ??
                  (state is CustomerDetailEmpty ? state.customer : null) ??
                  widget.customer;

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              _CustomerSliverAppBar(
                customer: customer,
                onSendReminder: () => _sendReminder(context, customer),
              ),
              if (state is CustomerDetailSuccess) ...<Widget>[
                _FilterRow(currentFilter: state.filter),
                if (state.visibleTransactions.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyStateView(
                      title: 'No transactions here',
                      message:
                          'Try selecting a different filter to see other entries.',
                    ),
                  )
                else ...<Widget>[
                  SliverFixedExtentList(
                    itemExtent: AppDimensions.transactionTileExtent,
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final TransactionEntity transaction =
                            state.visibleTransactions[index];
                        return TransactionTile(
                          transaction: transaction,
                        );
                      },
                      childCount: state.visibleTransactions.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: state.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(AppDimensions.pagePadding),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox(height: AppDimensions.space4XL),
                  ),
                ],
              ] else if (state is CustomerDetailLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is CustomerDetailEmpty)
                const SliverFillRemaining(
                  child: EmptyStateView(
                    title: 'No transactions yet',
                    message:
                        'Once you add entries for this customer they will show here.',
                  ),
                )
              else if (state is CustomerDetailFailure)
                SliverFillRemaining(
                  child: BrandedErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<CustomerDetailBloc>()
                        .add(const CustomerDetailRefreshed()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders the pinned app bar, scrollable info card, and Send Reminder button
/// grouped inside a [SliverMainAxisGroup] so the app bar pins independently
/// while the card and button scroll away with the rest of the content.
class _CustomerSliverAppBar extends StatelessWidget {
  const _CustomerSliverAppBar({
    required this.customer,
    required this.onSendReminder,
  });

  final CustomerEntity customer;
  final VoidCallback onSendReminder;

  /// Orange color matching the design spec for pending and the reminder button.
  static const Color _orange = Color(0xFFE87722);

  /// Green color for the received metric.
  static const Color _green = Color(0xFF16C35B);

  @override
  Widget build(BuildContext context) {
    // SliverMainAxisGroup groups the pinned SliverAppBar together with the
    // scrollable card and button so they form a single logical sliver unit
    // while still allowing the app bar to stay pinned independently.
    return SliverMainAxisGroup(
      slivers: <Widget>[
        // Pinned app bar: simple green bar with back arrow and centered name.
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            customer.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Info card: contact line + three metrics row.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.spaceMD,
              AppDimensions.pagePadding,
              0,
            ),
            child: Material(
              elevation: 3,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePadding,
                  vertical: AppDimensions.spaceMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Contact line.
                    Text(
                      'Contact: ${customer.phone}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6D7C74),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Three metrics in a row.
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _MetricItem(
                            amount: customer.totalSale.toInr,
                            label: 'Total Sale',
                            amountColor: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: _MetricItem(
                            amount: customer.totalReceived.toInr,
                            label: 'Received',
                            amountColor: _green,
                          ),
                        ),
                        Expanded(
                          child: _MetricItem(
                            amount: customer.balance.abs().toInr,
                            label: 'Pending',
                            amountColor: _orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Full-width orange pill "Send Reminder" button.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.spaceMD,
              AppDimensions.pagePadding,
              0,
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: onSendReminder,
                icon: const Icon(Icons.notifications_outlined, size: 20),
                label: const Text(
                  'Send Reminder',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single metric column used inside the customer info card.
class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.amount,
    required this.label,
    required this.amountColor,
  });

  final String amount;
  final String label;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6D7C74),
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({this.currentFilter});

  final TransactionType? currentFilter;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
          vertical: AppDimensions.spaceMD,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              _Chip(
                label: 'All',
                selected: currentFilter == null,
                onSelected: () => context
                    .read<CustomerDetailBloc>()
                    .add(const CustomerDetailFilterChanged()),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              _Chip(
                label: 'Sale',
                selected: currentFilter == TransactionType.sale,
                onSelected: () => context.read<CustomerDetailBloc>().add(
                      const CustomerDetailFilterChanged(
                        filter: TransactionType.sale,
                      ),
                    ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              _Chip(
                label: 'Payment Received',
                selected: currentFilter == TransactionType.payment,
                onSelected: () => context.read<CustomerDetailBloc>().add(
                      const CustomerDetailFilterChanged(
                        filter: TransactionType.payment,
                      ),
                    ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              _Chip(
                label: 'Pending Amount',
                selected: currentFilter == TransactionType.credit,
                onSelected: () => context.read<CustomerDetailBloc>().add(
                      const CustomerDetailFilterChanged(
                        filter: TransactionType.credit,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTextStyles.label.copyWith(
        color: selected ? AppColors.primary : null,
        fontWeight: selected ? FontWeight.w700 : null,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

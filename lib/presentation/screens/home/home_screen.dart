import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/core/utils/extensions/string_extension.dart';
import 'package:apna_business_app/domain/entities/customer_entity.dart';
import 'package:apna_business_app/domain/entities/home_feed_entity.dart';
import 'package:apna_business_app/domain/entities/home_user_info.dart';
import 'package:apna_business_app/domain/entities/transaction_entity.dart';
import 'package:apna_business_app/presentation/blocs/home/home_bloc.dart';
import 'package:apna_business_app/presentation/screens/home/widgets/customer_tile.dart';
import 'package:apna_business_app/presentation/screens/home/widgets/home_loading_view.dart';
import 'package:apna_business_app/presentation/screens/home/widgets/transaction_tile.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:apna_business_app/presentation/widgets/error_views/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Home dashboard with four preserved tabs.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _dashboardController;
  late final ScrollController _transactionsController;
  late final ScrollController _customersController;

  @override
  void initState() {
    super.initState();
    _dashboardController = ScrollController()
      ..addListener(() => _maybeLoadMore(_dashboardController, 0));
    _transactionsController = ScrollController()
      ..addListener(() => _maybeLoadMore(_transactionsController, 1));
    _customersController = ScrollController()
      ..addListener(() => _maybeLoadMore(_customersController, 2));
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    _transactionsController.dispose();
    _customersController.dispose();
    super.dispose();
  }

  void _maybeLoadMore(ScrollController controller, int tabIndex) {
    if (!controller.hasClients) {
      return;
    }
    final double threshold = controller.position.maxScrollExtent *
        AppConstants.paginationScrollThreshold;
    final HomeState state = context.read<HomeBloc>().state;
    if (state is! HomeSuccess || state.tabIndex != tabIndex) {
      return;
    }
    if (controller.position.pixels >= threshold) {
      context.read<HomeBloc>().add(const HomeLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    final HomeBloc homeBloc = context.read<HomeBloc>();
    homeBloc.add(const HomeRefreshed());
    await homeBloc.stream
        .firstWhere((HomeState state) => state is! HomeLoading);
  }

  Future<void> _openBusinessAssistant() async {
    await context.push(RouteNames.businessAssistant);
    if (!mounted) {
      return;
    }
    context.read<HomeBloc>().add(const HomeRefreshed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (HomeState previous, HomeState current) => previous != current,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: switch (state) {
            HomeLoading() => const HomeLoadingView(),
            HomeFailure() => BrandedErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeStarted()),
              ),
            HomeEmpty() => _HomeEmptyContent(
                tabIndex: state.tabIndex,
                onBusinessAssistantTap: _openBusinessAssistant,
              ),
            HomeSuccess() => _HomeContent(
                state: state,
                dashboardController: _dashboardController,
                transactionsController: _transactionsController,
                customersController: _customersController,
                onRefresh: _onRefresh,
                onBusinessAssistantTap: _openBusinessAssistant,
              ),
            _ => const SizedBox.shrink(),
          },
          floatingActionButton: (state is HomeSuccess && state.tabIndex == 0) ||
              state is HomeEmpty
              ? FloatingActionButton(
                  onPressed: _openBusinessAssistant,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 34),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _HomeBottomNavigation(
            selectedIndex: state.tabIndex,
            onChanged: (int index) {
              context.read<HomeBloc>().add(HomeTabChanged(index));
            },
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.dashboardController,
    required this.transactionsController,
    required this.customersController,
    required this.onRefresh,
    required this.onBusinessAssistantTap,
  });

  final HomeSuccess state;
  final ScrollController dashboardController;
  final ScrollController transactionsController;
  final ScrollController customersController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onBusinessAssistantTap;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: state.tabIndex,
      children: <Widget>[
        _DashboardTab(
          state: state,
          controller: dashboardController,
          onRefresh: onRefresh,
        ),
        _TransactionsTab(
          controller: transactionsController,
          state: state,
          onRefresh: onRefresh,
        ),
        _CustomersTab(
          controller: customersController,
          state: state,
          onRefresh: onRefresh,
        ),
        _SettingsShortcutTab(
          onBusinessAssistantTap: onBusinessAssistantTap,
        ),
      ],
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.state,
    required this.controller,
    required this.onRefresh,
  });

  final HomeSuccess state;
  final ScrollController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final List<_DashboardMetric> metrics = _buildMetrics(state);
    final _TopCustomerViewData? topCustomer = _topCustomer(state);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _DashboardHeader(
              metrics: metrics,
              userInfo: state.userInfo,
            ),
          ),
          if (topCustomer != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePadding,
                  AppDimensions.spaceLG,
                  AppDimensions.pagePadding,
                  0,
                ),
                child: _TopCustomerCard(customer: topCustomer),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceLG,
                AppDimensions.pagePadding,
                AppDimensions.space4XL,
              ),
              child: _RecentTransactionsCard(
                transactions: state.dashboard.feedItems,
                isLoadingMore: state.isLoadingMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.metrics,
    required this.userInfo,
  });

  // Visible green height below the status bar (device-independent design height)
  static const double _visibleGreenHeight = 138.0;
  // How many px of the metric cards overlap into the green banner
  static const double _metricsOverlap = 52.0;
  static const double _cardAspectRatio = 1.75;

  final List<_DashboardMetric> metrics;
  final HomeUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    // Accounts for edge-to-edge rendering on modern Android/iOS where the body
    // extends behind the transparent status bar / camera cutout.
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double backgroundHeight = statusBarHeight + _visibleGreenHeight;
    final double metricsTop = backgroundHeight - _metricsOverlap;

    final String greetingName = userInfo.fullName.trim().isEmpty
        ? 'Namaste 🙏'
        : 'Namaste, ${userInfo.fullName.trim()} 🙏';
    final String businessLine = [
      userInfo.businessName.trim(),
      userInfo.businessLocation.trim(),
    ].where((String value) => value.isNotEmpty).join(' · ');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double gridWidth =
            constraints.maxWidth - 2 * AppDimensions.pagePadding;
        final double cardWidth = (gridWidth - AppDimensions.spaceMD) / 2;
        final double cardHeight = cardWidth / _cardAspectRatio;
        final double metricsHeight = cardHeight * 2 + AppDimensions.spaceMD;
        final double totalHeight = metricsTop + metricsHeight;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: backgroundHeight,
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.spaceXXL,
                    statusBarHeight + AppDimensions.spaceLG,
                    AppDimensions.spaceXXL,
                    AppDimensions.spaceXXL,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(42),
                      bottomRight: Radius.circular(42),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              greetingName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceMD),
                            if (businessLine.isNotEmpty)
                              Text(
                                businessLine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFF1FFF7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceLG),
                      _NotificationBell(count: userInfo.unreadNotifications),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppDimensions.pagePadding,
                right: AppDimensions.pagePadding,
                top: metricsTop,
                child: _MetricsGrid(
                  metrics: metrics,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.metrics,
    required this.cardWidth,
    required this.cardHeight,
  });

  final List<_DashboardMetric> metrics;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _MetricCard(metric: metrics[0]),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _MetricCard(metric: metrics[1]),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _MetricCard(metric: metrics[2]),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _MetricCard(metric: metrics[3]),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
  });

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(metric.icon, size: 24, color: metric.color),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    metric.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF556074),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              metric.amount.toInr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF18233A),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCustomerCard extends StatelessWidget {
  const _TopCustomerCard({
    required this.customer,
  });

  final _TopCustomerViewData customer;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                const Expanded(
                  child: Text(
                    'Top Customer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF18233A),
                    ),
                  ),
                ),
                if (customer.details != null)
                  TextButton(
                    onPressed: () => context.push(
                      '${RouteNames.customerDetail}/${customer.details!.id}',
                      extra: customer.details!,
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFD8F8E2),
                      foregroundColor: const Color(0xFF088F39),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceXL,
                        vertical: AppDimensions.spaceMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'View',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              customer.name,
              style: AppTextStyles.title.copyWith(
                fontSize: 16,
                color: const Color(0xFF18233A),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXS),
            Text(
              'Pending: ${customer.pendingAmount.toInr}',
              style: AppTextStyles.bodyMuted.copyWith(
                fontSize: 14,
                color: const Color(0xFF5C697D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.transactions,
    required this.isLoadingMore,
  });

  final List<TransactionEntity> transactions;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final List<TransactionEntity> visibleTransactions =
        transactions.take(3).toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
                SizedBox(width: AppDimensions.spaceSM),
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18233A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            if (visibleTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceLG),
                child: Text(
                  'No recent transaction found.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C697D),
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: visibleTransactions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(
                  height: AppDimensions.spaceXL,
                  color: Color(0xFFEAECEF),
                ),
                itemBuilder: (BuildContext context, int index) {
                  return _CompactTransactionRow(
                    transaction: visibleTransactions[index],
                  );
                },
              ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.only(top: AppDimensions.spaceLG),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactTransactionRow extends StatelessWidget {
  const _CompactTransactionRow({
    required this.transaction,
  });

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final Color amountColor = switch (transaction.type) {
      TransactionType.expense => AppColors.expense,
      TransactionType.payment => AppColors.primary,
      TransactionType.credit => AppColors.warning,
      TransactionType.sale => const Color(0xFF18233A),
    };

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (transaction.customerName.trim().isNotEmpty) ...<Widget>[
                Text(
                  transaction.customerName,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF18233A),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXS),
              ],
              Text(
                _labelForType(transaction.type),
                style: AppTextStyles.bodyMuted.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF5C697D),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              '${transaction.isPositive && transaction.type == TransactionType.payment ? '+' : ''}${transaction.amount.toInr}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXS),
            Text(
              _formatShortDate(transaction.createdAt),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7D889B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransactionsTab extends StatefulWidget {
  const _TransactionsTab({
    required this.controller,
    required this.state,
    required this.onRefresh,
  });

  final ScrollController controller;
  final HomeSuccess state;
  final Future<void> Function() onRefresh;

  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  _TransactionPageFilter _activeFilter = _TransactionPageFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionEntity> get _filtered {
    return widget.state.transactions.where((TransactionEntity t) {
      final bool matchesType = switch (_activeFilter) {
        _TransactionPageFilter.all => true,
        _TransactionPageFilter.sale => t.type == TransactionType.sale,
        _TransactionPageFilter.paymentReceived =>
          t.type == TransactionType.payment,
        _TransactionPageFilter.pendingAmount => _isPendingAmountTransaction(t),
        _TransactionPageFilter.expense => t.type == TransactionType.expense,
      };
      final String q = _searchQuery.toLowerCase().trim();
      final bool matchesSearch = q.isEmpty ||
          t.customerName.toLowerCase().contains(q) ||
          t.subtitle.toLowerCase().contains(q);
      return matchesType && matchesSearch;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final List<TransactionEntity> filtered = _filtered;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: widget.controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _TransactionHeader(statusBarHeight: statusBarHeight),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceLG,
                AppDimensions.pagePadding,
                0,
              ),
              child: _AppSearchBar(
                controller: _searchController,
                onChanged: (String value) =>
                    setState(() => _searchQuery = value),
                hintText: 'Search transactions...',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceMD,
                AppDimensions.pagePadding,
                0,
              ),
              child: _TransactionFilterRow(
                activeFilter: _activeFilter,
                onChanged: (_TransactionPageFilter f) =>
                    setState(() => _activeFilter = f),
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.space3XL),
                  child: Text(
                    'No transactions found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C697D),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                top: AppDimensions.spaceMD,
                bottom: AppDimensions.space4XL,
              ),
              sliver: SliverList.builder(
                itemCount:
                    filtered.length + (widget.state.isLoadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= filtered.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceLG,
                        ),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final TransactionEntity t = filtered[index];
                  return TransactionTile(
                    transaction: t,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _isPendingAmountTransaction(TransactionEntity transaction) {
    return transaction.type == TransactionType.credit ||
        (transaction.type == TransactionType.sale &&
            transaction.subtitle.toLowerCase().contains('credit'));
  }
}

enum _TransactionPageFilter {
  all,
  sale,
  paymentReceived,
  pendingAmount,
  expense,
}

class _TransactionHeader extends StatelessWidget {
  const _TransactionHeader({required this.statusBarHeight});

  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spaceSM,
        statusBarHeight + AppDimensions.spaceSM,
        AppDimensions.spaceXXL,
        AppDimensions.spaceLG,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeTabChanged(0)),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            iconSize: 24,
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
          ),
          const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared search bar used on both the Transactions and Customers tabs.
class _AppSearchBar extends StatelessWidget {
  const _AppSearchBar({
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceLG,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF18233A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionFilterRow extends StatelessWidget {
  const _TransactionFilterRow({
    required this.activeFilter,
    required this.onChanged,
  });

  final _TransactionPageFilter activeFilter;
  final ValueChanged<_TransactionPageFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<(String, _TransactionPageFilter)> filters =
        <(String, _TransactionPageFilter)>[
      ('All', _TransactionPageFilter.all),
      ('Sale', _TransactionPageFilter.sale),
      ('Payment Received', _TransactionPageFilter.paymentReceived),
      ('Pending Amount', _TransactionPageFilter.pendingAmount),
      ('Expense', _TransactionPageFilter.expense),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map(((String, _TransactionPageFilter) f) {
          final bool isActive = activeFilter == f.$2;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceSM),
            child: GestureDetector(
              onTap: () => onChanged(f.$2),
              child: AnimatedContainer(
                duration: AppDimensions.quickDuration,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceSM,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color:
                        isActive ? AppColors.primary : const Color(0xFFDDE1E7),
                  ),
                ),
                child: Text(
                  f.$1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : const Color(0xFF556074),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CustomersTab extends StatefulWidget {
  const _CustomersTab({
    required this.controller,
    required this.state,
    required this.onRefresh,
  });

  final ScrollController controller;
  final HomeSuccess state;
  final Future<void> Function() onRefresh;

  @override
  State<_CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<_CustomersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerEntity> get _filtered {
    final String q = _searchQuery.toLowerCase().trim();
    if (q.isEmpty) {
      return widget.state.customers;
    }
    return widget.state.customers.where((CustomerEntity c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  double get _totalPending {
    return widget.state.customers
        .where((CustomerEntity c) => c.balance > 0)
        .fold(0, (double sum, CustomerEntity c) => sum + c.balance);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final List<CustomerEntity> filtered = _filtered;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: widget.controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _CustomersHeader(statusBarHeight: statusBarHeight),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceLG,
                AppDimensions.pagePadding,
                0,
              ),
              child: _AppSearchBar(
                controller: _searchController,
                onChanged: (String value) =>
                    setState(() => _searchQuery = value),
                hintText: 'Search customer...',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceLG,
                AppDimensions.pagePadding,
                AppDimensions.spaceSM,
              ),
              child: _CustomersSummaryCard(
                totalCustomers: widget.state.customers.length,
                totalPending: _totalPending,
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.space3XL),
                  child: Text(
                    'No customers found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C697D),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                top: AppDimensions.spaceSM,
                bottom: AppDimensions.space4XL,
              ),
              sliver: SliverList.builder(
                itemCount:
                    filtered.length + (widget.state.isLoadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= filtered.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spaceLG,
                        ),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return CustomerTile(customer: filtered[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomersHeader extends StatelessWidget {
  const _CustomersHeader({
    required this.statusBarHeight,
  });

  final double statusBarHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spaceSM,
        statusBarHeight + AppDimensions.spaceSM,
        AppDimensions.spaceXXL,
        AppDimensions.spaceLG,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeTabChanged(0)),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            iconSize: 24,
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
          ),
          const Text(
            'Customers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomersSummaryCard extends StatelessWidget {
  const _CustomersSummaryCard({
    required this.totalCustomers,
    required this.totalPending,
  });

  final int totalCustomers;
  final double totalPending;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceLG,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$totalCustomers',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18233A),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXXS),
                    const Text(
                      'Total Customers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6D7C74),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFE3E8E6),
              indent: AppDimensions.spaceLG,
              endIndent: AppDimensions.spaceLG,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceLG,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      totalPending.toInr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE87722),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXXS),
                    const Text(
                      'Total Pending',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6D7C74),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF08B44A),
                borderRadius: BorderRadius.circular(36),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3131),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<({IconData icon, String label})> items =
        <({IconData icon, String label})>[
      (icon: Icons.trending_up_rounded, label: 'Home'),
      (icon: Icons.receipt_long_outlined, label: 'Transactions'),
      (icon: Icons.group_outlined, label: 'Customers'),
      (icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            children: List<Widget>.generate(items.length, (int index) {
              final bool isSelected = selectedIndex == index;
              final item = items[index];
              final Color color =
                  isSelected ? AppColors.primary : const Color(0xFFA1AABA);

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(index),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(item.icon, size: 26, color: color),
                        const SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SettingsShortcutTab extends StatelessWidget {
  const _SettingsShortcutTab({
    required this.onBusinessAssistantTap,
  });

  final Future<void> Function() onBusinessAssistantTap;

  @override
  Widget build(BuildContext context) {
    final List<
            ({
              IconData icon,
              String title,
              String subtitle,
              VoidCallback onTap
            })> options =
        <({IconData icon, String title, String subtitle, VoidCallback onTap})>[
      (
        icon: Icons.person_outline,
        title: 'Profile & Settings',
        subtitle: 'Theme, language, notifications, and logout',
        onTap: () => context.push(RouteNames.profile),
      ),
      (
        icon: Icons.smart_toy_outlined,
        title: 'Business Assistant',
        subtitle: 'AI-powered help for payments, reminders, and reports',
        onTap: () => onBusinessAssistantTap(),
      ),
      (
        icon: Icons.notifications_outlined,
        title: 'Payment Reminders',
        subtitle: 'Send manual or auto reminders to customers',
        onTap: () => context.push(RouteNames.reminders),
      ),
      (
        icon: Icons.inventory_2_outlined,
        title: 'Inventory',
        subtitle: 'Stock manage karo — add, update, delete items',
        onTap: () => context.push(RouteNames.inventory),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      itemCount: options.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Quick access', style: AppTextStyles.headline),
                  const SizedBox(height: AppDimensions.spaceSM),
                  const Text(
                    'Jump into the dedicated profile screen to manage account-level preferences.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppDimensions.spaceLG),
                  FilledButton(
                    onPressed: () => context.push(RouteNames.profile),
                    child: const Text('Open Profile'),
                  ),
                ],
              ),
            ),
          );
        }

        final option = options[index - 1];
        return Card(
          margin: const EdgeInsets.only(top: AppDimensions.spaceMD),
          child: ListTile(
            leading: Icon(option.icon),
            title: Text(option.title),
            subtitle: Text(option.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: option.onTap,
          ),
        );
      },
    );
  }
}

List<_DashboardMetric> _buildMetrics(HomeSuccess state) {
  const List<({IconData icon, Color color, String fallbackTitle})> config =
      <({IconData icon, Color color, String fallbackTitle})>[
    (
      icon: Icons.trending_up_rounded,
      color: Color(0xFF10A943),
      fallbackTitle: 'Today’s sales',
    ),
    (
      icon: Icons.arrow_circle_down_outlined,
      color: Color(0xFF2463F2),
      fallbackTitle: 'Today’s Received Amount',
    ),
    (
      icon: Icons.access_time_rounded,
      color: Color(0xFFFF5A00),
      fallbackTitle: 'Pending',
    ),
    (
      icon: Icons.trending_down_rounded,
      color: Color(0xFFE32121),
      fallbackTitle: 'Kharcha',
    ),
  ];

  return List<_DashboardMetric>.generate(
    config.length,
    (int index) {
      final SummaryMetricEntity? metric = index < state.dashboard.metrics.length
          ? state.dashboard.metrics[index]
          : null;
      final item = config[index];
      return _DashboardMetric(
        title: metric?.title ?? item.fallbackTitle,
        amount: metric?.amount ?? 0,
        icon: item.icon,
        color: item.color,
      );
    },
    growable: false,
  );
}

_TopCustomerViewData? _topCustomer(HomeSuccess state) {
  final HomeUserInfo userInfo = state.userInfo;
  if ((userInfo.topCustomerName ?? '').trim().isEmpty ||
      userInfo.topCustomerPending == null) {
    return null;
  }

  CustomerEntity? customerDetails;
  if (userInfo.topCustomerId != null) {
    for (final CustomerEntity customer in state.customers) {
      if (customer.id == userInfo.topCustomerId) {
        customerDetails = customer;
        break;
      }
    }
  }

  return _TopCustomerViewData(
    name: userInfo.topCustomerName!.trim(),
    pendingAmount: userInfo.topCustomerPending!,
    details: customerDetails,
  );
}

String _labelForType(TransactionType type) {
  return switch (type) {
    TransactionType.sale => 'Sale',
    TransactionType.payment => 'Payment Received',
    TransactionType.credit => 'Pending Amount',
    TransactionType.expense => 'Expense',
  };
}

String _formatShortDate(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

final class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
}

final class _TopCustomerViewData {
  const _TopCustomerViewData({
    required this.name,
    required this.pendingAmount,
    required this.details,
  });

  final String name;
  final double pendingAmount;
  final CustomerEntity? details;
}

// ── Empty State Widgets ───────────────────────────────────────────────────────

/// Root widget for the empty state. Mirrors [_HomeContent]'s IndexedStack so
/// that tab-switching and the bottom navigation work identically.
class _HomeEmptyContent extends StatelessWidget {
  const _HomeEmptyContent({
    required this.tabIndex,
    required this.onBusinessAssistantTap,
  });

  final int tabIndex;
  final Future<void> Function() onBusinessAssistantTap;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: tabIndex,
      children: <Widget>[
        _EmptyDashboardTab(onBusinessAssistantTap: onBusinessAssistantTap),
        const _EmptySimpleTab(
          headerTitle: 'Transactions',
          icon: Icons.receipt_long_rounded,
          title: 'No Transactions Yet',
          subtitle:
              'Aapke transactions yahan dikhenge.\nNeeche + button tap karke pehla transaction add karo!',
        ),
        const _EmptySimpleTab(
          headerTitle: 'Customers',
          icon: Icons.people_outline_rounded,
          title: 'No Customers Yet',
          subtitle:
              'Customers yahan dikhenge jab aap pehla\nsale ya payment record karoge.',
        ),
        _SettingsShortcutTab(onBusinessAssistantTap: onBusinessAssistantTap),
      ],
    );
  }
}

/// Full empty dashboard: same green header, placeholder ₹0 metric cards,
/// a get-started CTA card, and an empty recent-transactions card.
class _EmptyDashboardTab extends StatelessWidget {
  const _EmptyDashboardTab({required this.onBusinessAssistantTap});

  final Future<void> Function() onBusinessAssistantTap;

  static const double _visibleGreenHeight = 138.0;
  static const double _metricsOverlap = 52.0;
  static const double _cardAspectRatio = 1.75;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double backgroundHeight = statusBarHeight + _visibleGreenHeight;
    final double metricsTop = backgroundHeight - _metricsOverlap;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              final double gridWidth =
                  constraints.maxWidth - 2 * AppDimensions.pagePadding;
              final double cardWidth =
                  (gridWidth - AppDimensions.spaceMD) / 2;
              final double cardHeight = cardWidth / _cardAspectRatio;
              final double totalHeight =
                  metricsTop + cardHeight * 2 + AppDimensions.spaceMD;

              return SizedBox(
                height: totalHeight,
                child: Stack(
                  children: <Widget>[
                    // Green banner
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: backgroundHeight,
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.spaceXXL,
                          statusBarHeight + AppDimensions.spaceLG,
                          AppDimensions.spaceXXL,
                          AppDimensions.spaceXXL,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(42),
                            bottomRight: Radius.circular(42),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Namaste 🙏',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.18,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spaceMD),
                                  Text(
                                    'Welcome to Apna Business',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFF1FFF7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _NotificationBell(count: 0),
                          ],
                        ),
                      ),
                    ),
                    // Placeholder ₹0 metric cards
                    Positioned(
                      left: AppDimensions.pagePadding,
                      right: AppDimensions.pagePadding,
                      top: metricsTop,
                      child: _EmptyMetricsGrid(
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Onboarding CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.spaceLG,
              AppDimensions.pagePadding,
              0,
            ),
            child: _GetStartedCard(onTap: onBusinessAssistantTap),
          ),
          // Empty transactions placeholder
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.spaceLG,
              AppDimensions.pagePadding,
              AppDimensions.space4XL,
            ),
            child: _EmptyRecentTransactionsCard(),
          ),
        ],
      ),
    );
  }
}

/// 2×2 grid of placeholder metric cards, all showing ₹0.
class _EmptyMetricsGrid extends StatelessWidget {
  const _EmptyMetricsGrid({
    required this.cardWidth,
    required this.cardHeight,
  });

  final double cardWidth;
  final double cardHeight;

  static const List<(String, IconData, Color)> _items =
      <(String, IconData, Color)>[
    ('Today\'s Sales', Icons.trending_up_rounded, Color(0xFF16C35B)),
    ('Received', Icons.account_balance_wallet_rounded, Color(0xFF3278F6)),
    ('Total Pending', Icons.hourglass_top_rounded, Color(0xFFFF9A1A)),
    ('Today\'s Expense', Icons.remove_circle_outline_rounded, Color(0xFFE5484D)),
  ];

  @override
  Widget build(BuildContext context) {
    Widget card(int i) => SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: _EmptyMetricCard(item: _items[i]),
        );
    const Widget gap = SizedBox(width: AppDimensions.spaceMD);
    const Widget rowGap = SizedBox(height: AppDimensions.spaceMD);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(children: <Widget>[card(0), gap, card(1)]),
        rowGap,
        Row(children: <Widget>[card(2), gap, card(3)]),
      ],
    );
  }
}

/// Single placeholder metric card showing ₹0 with muted styling.
class _EmptyMetricCard extends StatelessWidget {
  const _EmptyMetricCard({required this.item});

  final (String, IconData, Color) item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(item.$2, size: 22, color: item.$3.withAlpha(120)),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B8C1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            const Text(
              '₹0',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCDD2D8),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding card that guides the user to add their first transaction.
class _GetStartedCard extends StatelessWidget {
  const _GetStartedCard({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF16C35B), Color(0xFF0A9D45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF16C35B).withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceMD),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: const Text('🚀',
                          style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: AppDimensions.spaceMD),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Get Started!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Apna pehla transaction add karein',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD4FAE5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                const _Step(emoji: '1️⃣', text: 'Neeche + button tap karo'),
                const SizedBox(height: AppDimensions.spaceSM),
                const _Step(
                    emoji: '2️⃣',
                    text: 'Sale, payment ya expense type karo'),
                const SizedBox(height: AppDimensions.spaceSM),
                const _Step(
                    emoji: '3️⃣', text: 'AI apna kaam karega — bas!'),
                const SizedBox(height: AppDimensions.spaceXL),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.add_circle_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: AppDimensions.spaceSM),
                      Text(
                        'Pehla Transaction Add Karo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD4FAE5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder card for the "Recent Transactions" section when empty.
class _EmptyRecentTransactionsCard extends StatelessWidget {
  const _EmptyRecentTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 30),
                SizedBox(width: AppDimensions.spaceSM),
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18233A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spaceXXL,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: const Color(0xFFE3E8E6)),
              ),
              child: const Column(
                children: <Widget>[
                  Text('📋', style: TextStyle(fontSize: 34)),
                  SizedBox(height: AppDimensions.spaceMD),
                  Text(
                    'Abhi koi transaction nahi hai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF556074),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    'Pehla transaction add karne ke baad\nyahan dikhai dega',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    textAlign: TextAlign.center,
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

/// Simple header + centered icon empty state for Transactions / Customers tabs.
class _EmptySimpleTab extends StatelessWidget {
  const _EmptySimpleTab({
    required this.headerTitle,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String headerTitle;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spaceSM,
            statusBarHeight + AppDimensions.spaceSM,
            AppDimensions.spaceXXL,
            AppDimensions.spaceLG,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () =>
                    context.read<HomeBloc>().add(const HomeTabChanged(0)),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
                iconSize: 24,
                padding: const EdgeInsets.all(AppDimensions.spaceSM),
              ),
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space3XL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 46, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18233A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6D7C74),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


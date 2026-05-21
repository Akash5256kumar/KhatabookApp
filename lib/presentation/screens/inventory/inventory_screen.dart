import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/domain/entities/inventory_entity.dart';
import 'package:apna_business_app/presentation/blocs/inventory/inventory_bloc.dart';
import 'package:apna_business_app/presentation/widgets/error_views/branded_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Inventory management screen — list, search, add, edit, delete items.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<InventoryItemEntity> _filter(List<InventoryItemEntity> items) {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((InventoryItemEntity i) {
      return i.productName.toLowerCase().contains(q) ||
          (i.category?.toLowerCase().contains(q) ?? false);
    }).toList(growable: false);
  }

  void _showUpsertSheet(InventoryItemEntity? item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider<InventoryBloc>.value(
        value: context.read<InventoryBloc>(),
        child: _UpsertSheet(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<InventoryBloc>().add(const InventoryRefreshed()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpsertSheet(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Column(
        children: <Widget>[
          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePadding,
              AppDimensions.spaceMD,
              AppDimensions.pagePadding,
              AppDimensions.spaceSM,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Product ya category search karo…',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMD,
                  vertical: AppDimensions.spaceMD,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                filled: true,
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<InventoryBloc, InventoryState>(
              listener: (BuildContext ctx, InventoryState state) {
                if (state is InventoryFailure) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (BuildContext ctx, InventoryState state) {
                return switch (state) {
                  InventoryLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  InventoryEmpty() => const _EmptyView(),
                  InventoryFailure() => BrandedErrorView(
                      message: state.message,
                      onRetry: () => ctx
                          .read<InventoryBloc>()
                          .add(const InventoryRefreshed()),
                    ),
                  InventorySuccess(items: final items) =>
                    _buildList(ctx, items),
                  InventoryActionInProgress(items: final items) => Stack(
                      children: <Widget>[
                        _buildList(ctx, items),
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(),
                        ),
                      ],
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext ctx, List<InventoryItemEntity> all) {
    final List<InventoryItemEntity> visible = _filter(all);
    if (visible.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'Koi item nahi hai' : '"$_query" nahi mila',
          style: AppTextStyles.bodyMuted,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: AppDimensions.pagePadding,
        right: AppDimensions.pagePadding,
        top: AppDimensions.spaceSM,
        bottom: 96,
      ),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.spaceSM),
      itemBuilder: (BuildContext c, int i) =>
          _InventoryTile(item: visible[i], onEdit: _showUpsertSheet),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item, required this.onEdit});

  final InventoryItemEntity item;
  final void Function(InventoryItemEntity) onEdit;

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = item.quantity <= 0;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceSM,
        ),
        leading: Container(
          width: AppDimensions.iconXL + 8,
          height: AppDimensions.iconXL + 8,
          decoration: BoxDecoration(
            color: isLowStock
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: isLowStock ? AppColors.error : AppColors.primary,
          ),
        ),
        title: Text(item.productName, style: AppTextStyles.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AppDimensions.spaceXXS),
            if (item.category != null)
              Text(
                item.category!,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            Text(
              '${item.quantity} ${item.unit}',
              style: AppTextStyles.bodyMuted.copyWith(
                color: isLowStock ? AppColors.error : null,
              ),
            ),
            if (item.lastPurchasePrice != null || item.lastSalePrice != null)
              Text(
                <String>[
                  if (item.lastPurchasePrice != null)
                    'Buy: ₹${item.lastPurchasePrice!.toStringAsFixed(0)}',
                  if (item.lastSalePrice != null)
                    'Sell: ₹${item.lastSalePrice!.toStringAsFixed(0)}',
                ].join('  |  '),
                style: AppTextStyles.label,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (item.lastSalePrice != null)
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spaceSM),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('Sell', style: AppTextStyles.label),
                    Text(
                      '₹${item.lastSalePrice!.toStringAsFixed(0)}',
                      style:
                          AppTextStyles.title.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'edit') {
                  onEdit(item);
                } else if (value == 'delete') {
                  _confirmDelete(context, item);
                }
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryItemEntity item) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('${item.productName} delete karna chahte ho?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(InventoryItemDeleted(item.id));
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppDimensions.spaceLG),
          Text('Koi item nahi hai', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.spaceSM),
          Text('+ Add Item button se stock add karo',
              style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}

// ── Add / Edit sheet ──────────────────────────────────────────────────────────

class _UpsertSheet extends StatefulWidget {
  const _UpsertSheet({this.item});

  final InventoryItemEntity? item;

  @override
  State<_UpsertSheet> createState() => _UpsertSheetState();
}

class _UpsertSheetState extends State<_UpsertSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _purchasePriceCtrl;
  late final TextEditingController _salePriceCtrl;

  @override
  void initState() {
    super.initState();
    final InventoryItemEntity? item = widget.item;
    _categoryCtrl = TextEditingController(text: item?.category ?? '');
    _nameCtrl = TextEditingController(text: item?.productName ?? '');
    _qtyCtrl = TextEditingController(
        text: item != null ? item.quantity.toString() : '');
    _unitCtrl = TextEditingController(text: item?.unit ?? 'kg');
    _purchasePriceCtrl = TextEditingController(
        text: item?.lastPurchasePrice?.toStringAsFixed(0) ?? '');
    _salePriceCtrl = TextEditingController(
        text: item?.lastSalePrice?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    super.dispose();
  }

  String? _requiredNumber(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field likhna zaroori hai';
    if (double.tryParse(v.trim()) == null) return 'Sahi number likho';
    if ((double.tryParse(v.trim()) ?? -1) < 0) return 'Amount 0 se kam nahi ho sakta';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<InventoryBloc>().add(
          InventoryItemUpserted(
            category: _categoryCtrl.text.trim().toLowerCase(),
            productName: _nameCtrl.text.trim().toLowerCase(),
            quantity: double.tryParse(_qtyCtrl.text.trim()) ?? 0,
            unit: _unitCtrl.text.trim().toLowerCase(),
            lastPurchasePrice: double.tryParse(_purchasePriceCtrl.text.trim()),
            lastSalePrice: double.tryParse(_salePriceCtrl.text.trim()),
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.item != null;
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.pagePadding,
        right: AppDimensions.pagePadding,
        top: AppDimensions.spaceXL,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppDimensions.spaceXXL,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              isEdit ? 'Item Update Karo' : 'Naya Item Add Karo',
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Category = general naam (Rice, Biscuit)\n'
              'Product = specific naam (Basmati Rice, Oreo)',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppDimensions.spaceLG),

            // Category — mandatory
            TextFormField(
              controller: _categoryCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category *',
                hintText: 'e.g. Rice, Biscuit, Cold Drink',
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Category likhna zaroori hai' : null,
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            // Product name — mandatory, locked after save
            TextFormField(
              controller: _nameCtrl,
              enabled: !isEdit,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Basmati Rice, Oreo',
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Product naam likhna zaroori hai' : null,
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            // Quantity + Unit
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantity *'),
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Quantity likhna zaroori hai';
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return 'Sahi number likho';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit *'),
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty) ? 'Unit likhna zaroori hai' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            // Purchase price + Selling price — both mandatory
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price *',
                      prefixText: '₹ ',
                    ),
                    validator: (String? v) =>
                        _requiredNumber(v, 'Purchase price'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: TextFormField(
                    controller: _salePriceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Selling Price *',
                      prefixText: '₹ ',
                    ),
                    validator: (String? v) =>
                        _requiredNumber(v, 'Selling price'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXXL),

            ElevatedButton(
              onPressed: _submit,
              child: Text(isEdit ? 'Update Karo' : 'Add Karo'),
            ),
          ],
        ),
      ),
    );
  }
}

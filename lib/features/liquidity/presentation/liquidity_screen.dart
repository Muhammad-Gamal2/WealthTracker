import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_signals.dart';
import 'package:wealth_tracker/features/liquidity/presentation/widgets/add_liquidity_dialog.dart';
import 'package:wealth_tracker/features/liquidity/presentation/widgets/liquidity_item_tile.dart';

class LiquidityScreen extends StatefulWidget {
  const LiquidityScreen({super.key});

  @override
  State<LiquidityScreen> createState() => _LiquidityScreenState();
}

class _LiquidityScreenState extends State<LiquidityScreen> {
  @override
  void initState() {
    super.initState();
    loadLiquidityItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquidity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadLiquidityItems,
          ),
        ],
      ),
      body: Watch((context) {
        if (liquidityLoadingSignal.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = liquidityItemsSignal.value;
        return Column(
          children: [
            _buildHeader(context, items),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No liquidity items yet.\nTap + to add.',
                          textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => LiquidityItemTile(
                        item: items[i],
                        onEdit: () => _showAddEditDialog(context, items[i]),
                        onDelete: () =>
                            _confirmDelete(context, items[i]),
                      ),
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<LiquidityEntity> items) {
    return FutureBuilder(
      future:
          sl<PriceUpdateService>().getLatestPrices(stockApiSymbols: const []),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final prices = snap.data!;
        final totalUsd =
            items.fold(0.0, (sum, i) => sum + i.amountUsd);
        final totalEgp = totalUsd * prices.usdToEgpRate;
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Liquidity',
                      style: Theme.of(context).textTheme.labelMedium),
                  Text(CurrencyFormatter.formatUsd(totalUsd),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(CurrencyFormatter.formatEgp(totalEgp),
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Rate',
                      style: Theme.of(context).textTheme.labelSmall),
                  Text(
                      '1 USD = ${CurrencyFormatter.formatNumber(prices.usdToEgpRate)} EGP',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, LiquidityEntity? existing) {
    showDialog(
        context: context,
        builder: (_) => AddLiquidityDialog(existing: existing));
  }

  void _confirmDelete(BuildContext context, LiquidityEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "${item.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteLiquidityItem(item.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

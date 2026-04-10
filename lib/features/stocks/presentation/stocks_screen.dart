import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_signals.dart';
import 'package:wealth_tracker/features/stocks/presentation/widgets/add_stock_dialog.dart';
import 'package:wealth_tracker/features/stocks/presentation/widgets/stock_item_tile.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  void initState() {
    super.initState();
    loadStockItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStockItems,
          ),
        ],
      ),
      body: Watch((context) {
        if (stocksLoadingSignal.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = stockItemsSignal.value;
        return Column(
          children: [
            _buildTotalHeader(context, items),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No stocks yet.\nTap + to add one.',
                          textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => StockItemTile(
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

  Widget _buildTotalHeader(BuildContext context, List<StockEntity> items) {
    return FutureBuilder(
      future: sl<PriceUpdateService>().getLatestPrices(
        stockApiSymbols: items.map((s) => s.apiSymbol).toList(),
      ),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final prices = snap.data!;
        double totalEgp = 0;
        for (final item in items) {
          final price = prices.stockPrices[item.apiSymbol] ?? 0;
          totalEgp += item.isEgx
              ? item.quantity * price
              : item.quantity * price * prices.usdToEgpRate;
        }
        final totalUsd =
            prices.usdToEgpRate > 0 ? totalEgp / prices.usdToEgpRate : 0;
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Portfolio',
                      style: Theme.of(context).textTheme.labelMedium),
                  Text(CurrencyFormatter.formatEgp(totalEgp),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(CurrencyFormatter.formatUsd(totalUsd.toDouble()),
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${items.length} stocks',
                      style: Theme.of(context).textTheme.labelSmall),
                  Text(
                      '${items.where((s) => s.isEgx).length} EGX · ${items.where((s) => s.isUs).length} US',
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, StockEntity? existing) {
    showDialog(
      context: context,
      builder: (_) => AddStockDialog(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, StockEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Stock'),
        content: Text('Remove ${item.symbol}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteStockItem(item.id);
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

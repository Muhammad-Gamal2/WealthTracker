import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_signals.dart';
import 'package:wealth_tracker/features/gold/presentation/widgets/add_gold_dialog.dart';
import 'package:wealth_tracker/features/gold/presentation/widgets/gold_item_tile.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  @override
  void initState() {
    super.initState();
    loadGoldItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh prices',
            onPressed: loadGoldItems,
          ),
        ],
      ),
      body: Watch((context) {
        if (goldLoadingSignal.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (goldErrorSignal.value != null) {
          return Center(child: Text('Error: ${goldErrorSignal.value}'));
        }

        final items = goldItemsSignal.value;
        final prices = sl<PriceUpdateService>();

        return Column(
          children: [
            _buildPriceHeader(context),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No gold items yet.\nTap + to add one.',
                          textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => GoldItemTile(
                        item: items[i],
                        onEdit: () => _showAddEditDialog(context, items[i]),
                        onDelete: () => _confirmDelete(context, items[i]),
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

  Widget _buildPriceHeader(BuildContext context) {
    // We show the cached gold prices from the price service
    return FutureBuilder(
      future: sl<PriceUpdateService>()
          .getLatestPrices(stockApiSymbols: const []),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final p = snap.data!;
        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Gold Prices (EGP/gram)',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _karatChip('24K',
                        CurrencyFormatter.formatEgp(p.goldPrice24k), context),
                    _karatChip('22K',
                        CurrencyFormatter.formatEgp(p.goldPrice22k), context),
                    _karatChip('21K',
                        CurrencyFormatter.formatEgp(p.goldPrice21k), context),
                    _karatChip('18K',
                        CurrencyFormatter.formatEgp(p.goldPrice18k), context),
                  ],
                ),
                if (p.isStale)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber,
                            size: 14,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 4),
                        Text('Prices may be outdated',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _karatChip(String karat, String price, BuildContext context) {
    return Column(
      children: [
        Text(karat,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(price, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showAddEditDialog(BuildContext context, GoldEntity? existing) {
    showDialog(
      context: context,
      builder: (_) => AddGoldDialog(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, GoldEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Gold Item'),
        content: Text('Remove "${item.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteGoldItem(item.id);
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

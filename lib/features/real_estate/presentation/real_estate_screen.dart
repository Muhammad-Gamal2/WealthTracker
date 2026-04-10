import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/utils/date_formatter.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_signals.dart';
import 'package:wealth_tracker/features/real_estate/presentation/widgets/add_real_estate_dialog.dart';
import 'package:wealth_tracker/features/real_estate/presentation/widgets/real_estate_item_tile.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  @override
  void initState() {
    super.initState();
    loadRealEstateItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real Estate')),
      body: Watch((context) {
        if (realEstateLoadingSignal.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = realEstateItemsSignal.value;
        return Column(
          children: [
            _buildHeader(context, items),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No properties yet.\nTap + to add.',
                          textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => RealEstateItemTile(
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

  Widget _buildHeader(
      BuildContext context, List<RealEstateEntity> items) {
    final totalCurrent =
        items.fold(0.0, (sum, i) => sum + i.currentValueEgp);
    final totalPurchase =
        items.fold(0.0, (sum, i) => sum + i.purchaseAmountEgp);
    final totalGain = totalCurrent - totalPurchase;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Value',
                  style: Theme.of(context).textTheme.labelMedium),
              Text(CurrencyFormatter.formatEgp(totalCurrent),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('Purchased: ${CurrencyFormatter.formatEgp(totalPurchase)}',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Total Gain',
                  style: Theme.of(context).textTheme.labelSmall),
              Text(
                CurrencyFormatter.formatEgp(totalGain),
                style: TextStyle(
                  color: totalGain >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(
      BuildContext context, RealEstateEntity? existing) {
    showDialog(
        context: context,
        builder: (_) => AddRealEstateDialog(existing: existing));
  }

  void _confirmDelete(BuildContext context, RealEstateEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Remove "${item.projectName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              deleteRealEstateItem(item.id);
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

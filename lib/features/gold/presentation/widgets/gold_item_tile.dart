import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';

class GoldItemTile extends StatelessWidget {
  final GoldEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoldItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          sl<PriceUpdateService>().getLatestPrices(stockApiSymbols: const []),
      builder: (context, snap) {
        final prices = snap.data;
        final pricePerGram = prices?.priceForKarat(item.karat) ?? 0;
        final totalEgp = item.weightGrams * pricePerGram;
        final totalUsd = prices != null && prices.usdToEgpRate > 0
            ? totalEgp / prices.usdToEgpRate
            : 0.0;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text('${item.karat}K',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            title: Text(item.label.isEmpty ? '${item.karat}K Gold' : item.label),
            subtitle: Text(
                '${CurrencyFormatter.formatGrams(item.weightGrams)} · ${item.karat}K'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatEgp(totalEgp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                Text(CurrencyFormatter.formatUsd(totalUsd),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6))),
              ],
            ),
            onTap: onEdit,
            onLongPress: onDelete,
          ),
        );
      },
    );
  }
}

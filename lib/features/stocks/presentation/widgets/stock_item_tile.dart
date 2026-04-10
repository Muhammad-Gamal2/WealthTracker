import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';

class StockItemTile extends StatelessWidget {
  final StockEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<PriceUpdateService>()
          .getLatestPrices(stockApiSymbols: [item.apiSymbol]),
      builder: (context, snap) {
        final prices = snap.data;
        final currentPrice = prices?.stockPrices[item.apiSymbol] ?? 0;
        final totalEgp = item.isEgx
            ? item.quantity * currentPrice
            : item.quantity * currentPrice * (prices?.usdToEgpRate ?? 1);
        final totalUsd = (prices?.usdToEgpRate ?? 1) > 0
            ? totalEgp / (prices?.usdToEgpRate ?? 1)
            : 0.0;

        final purchaseEgp = item.isEgx
            ? item.quantity * item.purchasePrice
            : item.quantity * item.purchasePrice * (prices?.usdToEgpRate ?? 1);
        final gainEgp = totalEgp - purchaseEgp;
        final gainPercent = purchaseEgp > 0 ? (gainEgp / purchaseEgp) * 100 : 0;
        final isPositive = gainEgp >= 0;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.isEgx
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.tertiaryContainer,
              child: Text(
                item.market,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.isEgx
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(item.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (item.name.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(item.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
            subtitle: Text(
                '${CurrencyFormatter.formatNumber(item.quantity)} shares · '
                'Current: ${item.isEgx ? CurrencyFormatter.formatEgp(currentPrice) : CurrencyFormatter.formatUsd(currentPrice)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatEgp(totalEgp),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  CurrencyFormatter.formatPercent(gainPercent.toDouble()),
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

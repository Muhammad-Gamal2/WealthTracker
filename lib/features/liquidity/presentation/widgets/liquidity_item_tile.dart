import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';

class LiquidityItemTile extends StatelessWidget {
  final LiquidityEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LiquidityItemTile({
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
        final rate = snap.data?.usdToEgpRate ?? 1;
        final egpValue = item.amountUsd * rate;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: const Text('\$',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(item.label.isEmpty ? 'Cash' : item.label),
            subtitle: Text(CurrencyFormatter.formatUsd(item.amountUsd)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatEgp(egpValue),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold)),
                Text('Rate: ${CurrencyFormatter.formatNumber(rate)}',
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

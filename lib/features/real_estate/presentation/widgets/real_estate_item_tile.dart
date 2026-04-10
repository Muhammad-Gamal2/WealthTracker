import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/utils/date_formatter.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';

class RealEstateItemTile extends StatelessWidget {
  final RealEstateEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RealEstateItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final current = item.currentValueEgp;
    final gain = item.gainEgp;
    final isPositive = gain >= 0;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(Icons.home,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        title: Text(item.projectName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Since ${DateFormatter.toDisplay(item.purchaseDate)} · '
          '${item.annualAppreciationPercent.toStringAsFixed(1)}%/yr',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyFormatter.formatEgp(current),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '${isPositive ? '+' : ''}${CurrencyFormatter.formatEgp(gain)}',
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }
}

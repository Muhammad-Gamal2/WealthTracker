import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';

class CategorySummaryCard extends StatelessWidget {
  final String title;
  final double valueEgp;
  final double valueUsd;
  final double percent;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const CategorySummaryCard({
    super.key,
    required this.title,
    required this.valueEgp,
    required this.valueUsd,
    required this.percent,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(title,
                      style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(CurrencyFormatter.formatEgp(valueEgp),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              Text(CurrencyFormatter.formatUsd(valueUsd),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';

class TotalWealthHeader extends StatelessWidget {
  final WealthSummary summary;
  final bool isLoading;
  final VoidCallback onRefresh;

  const TotalWealthHeader({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Wealth',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 6),
          isLoading
              ? const CircularProgressIndicator()
              : Text(
                  CurrencyFormatter.formatEgp(summary.totalEgp),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                ),
          const SizedBox(height: 4),
          if (!isLoading)
            Text(
              CurrencyFormatter.formatUsd(summary.totalUsd),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
            ),
        ],
      ),
    );
  }
}

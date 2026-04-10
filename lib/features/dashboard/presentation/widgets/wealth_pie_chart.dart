import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';

class WealthPieChart extends StatefulWidget {
  final WealthSummary summary;
  final void Function(int index) onSectionTap;

  const WealthPieChart({
    super.key,
    required this.summary,
    required this.onSectionTap,
  });

  @override
  State<WealthPieChart> createState() => _WealthPieChartState();
}

class _WealthPieChartState extends State<WealthPieChart> {
  int? _touchedIndex;

  static const _colors = [
    Color(0xFFFFD700), // Gold - yellow
    Color(0xFF4CAF50), // Stocks - green
    Color(0xFF2196F3), // Liquidity - blue
    Color(0xFFFF5722), // Real Estate - orange
  ];

  static const _labels = ['Gold', 'Stocks', 'Liquidity', 'Real Estate'];

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    if (summary.totalEgp == 0) {
      return const Center(
        child: Text(
          'Add items to see your wealth breakdown',
          textAlign: TextAlign.center,
        ),
      );
    }

    final values = [
      summary.goldValueEgp,
      summary.stocksValueEgp,
      summary.liquidityValueEgp,
      summary.realEstateValueEgp,
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    setState(() => _touchedIndex = null);
                    return;
                  }
                  final index =
                      response.touchedSection!.touchedSectionIndex;
                  setState(() => _touchedIndex = index);
                  if (event is FlTapUpEvent) {
                    widget.onSectionTap(index);
                  }
                },
              ),
              sections: List.generate(4, (i) {
                final isTouched = i == _touchedIndex;
                final value = values[i];
                if (value <= 0) return null;
                return PieChartSectionData(
                  value: value,
                  color: _colors[i],
                  radius: isTouched ? 65 : 55,
                  title: '${values[i] / summary.totalEgp * 100 < 5 ? '' : '${(values[i] / summary.totalEgp * 100).toStringAsFixed(1)}%'}',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: isTouched
                      ? _Badge(_labels[i],
                          CurrencyFormatter.formatEgp(values[i]))
                      : null,
                  badgePositionPercentageOffset: 1.3,
                );
              }).whereType<PieChartSectionData>().toList(),
              centerSpaceRadius: 45,
              sectionsSpace: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(4, (i) {
            if (values[i] <= 0) return const SizedBox.shrink();
            return _LegendItem(
              color: _colors[i],
              label: _labels[i],
              value: CurrencyFormatter.formatEgp(values[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  const _Badge(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ],
        ),
      ],
    );
  }
}

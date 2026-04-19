import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
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
    ObsidianTheme.gold,
    ObsidianTheme.green,
    ObsidianTheme.cyan,
    ObsidianTheme.orange,
  ];

  static const _labels = ['Gold', 'Stocks', 'Liquidity', 'Real Estate'];

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    if (summary.totalEgp == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Add items to see your wealth breakdown',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: ObsidianTheme.text3,
            ),
          ),
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
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
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
                  sections: _buildSections(values, summary.totalEgp),
                  centerSpaceRadius: 56,
                  sectionsSpace: 2,
                ),
              ),
              // Center text
              _buildCenterText(values, summary.totalEgp),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(4, (i) {
            if (values[i] <= 0) return const SizedBox.shrink();
            final isActive = _touchedIndex == null || _touchedIndex == i;
            return _LegendItem(
              color: _colors[i],
              label: _labels[i],
              percent: (values[i] / summary.totalEgp * 100),
              isActive: isActive,
            );
          }),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
      List<double> values, double total) {
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < 4; i++) {
      final value = values[i];
      if (value <= 0) continue;
      final isTouched = i == _touchedIndex;
      final pct = (value / total * 100);
      sections.add(
        PieChartSectionData(
          value: value,
          color: _colors[i],
          radius: isTouched ? 48 : 40,
          title: pct < 5 ? '' : '${pct.toStringAsFixed(1)}%',
          titleStyle: GoogleFonts.dmMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }
    return sections;
  }

  Widget _buildCenterText(List<double> values, double total) {
    if (_touchedIndex != null &&
        _touchedIndex! >= 0 &&
        _touchedIndex! < 4 &&
        values[_touchedIndex!] > 0) {
      final pct = (values[_touchedIndex!] / total * 100);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: GoogleFonts.dmMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ObsidianTheme.text1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _labels[_touchedIndex!],
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ObsidianTheme.text3,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ObsidianTheme.text1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Portfolio',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ObsidianTheme.text3,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;
  final bool isActive;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1.0 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? ObsidianTheme.text1 : ObsidianTheme.text2,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

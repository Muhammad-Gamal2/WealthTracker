import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/utils/date_formatter.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';

class WealthLineChart extends StatelessWidget {
  final List<SnapshotEntity> snapshots;

  const WealthLineChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    if (snapshots.length < 2) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Chart will appear after 2+ days of data',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: ObsidianTheme.text3,
            ),
          ),
        ),
      );
    }

    final spots = snapshots.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalValueEgp);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;
    final showDots = snapshots.length <= 30;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              getTooltipColor: (_) => ObsidianTheme.surface2,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final snap = snapshots[idx];
                return LineTooltipItem(
                  '${snap.date}\n${CurrencyFormatter.formatEgp(snap.totalValueEgp)}',
                  GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ObsidianTheme.text1,
                  ),
                );
              }).toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: padding > 0 ? (maxY - minY) / 4 : null,
            getDrawingHorizontalLine: (value) => FlLine(
              color: ObsidianTheme.inputFill, // rgba(255,255,255,0.05)
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    _shortAmount(value),
                    style: GoogleFonts.dmMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: ObsidianTheme.text3,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: snapshots.length > 10
                    ? (snapshots.length / 4).roundToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= snapshots.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormatter.toShort(
                          _parseDate(snapshots[idx].date)),
                      style: GoogleFonts.dmMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: ObsidianTheme.text3,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: ObsidianTheme.accent,
              barWidth: 2.2,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, percent, bar, index) {
                  final isLast = index == spots.length - 1;
                  if (isLast) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: ObsidianTheme.accent,
                      strokeWidth: 2,
                      strokeColor: ObsidianTheme.accent.withValues(alpha: 0.3),
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 2.5,
                    color: ObsidianTheme.accent,
                    strokeWidth: 1,
                    strokeColor: ObsidianTheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ObsidianTheme.accent.withValues(alpha: 0.28),
                    ObsidianTheme.accent.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortAmount(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}

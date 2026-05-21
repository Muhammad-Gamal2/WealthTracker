import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';

class GainBadge extends StatelessWidget {
  final double percent;

  const GainBadge({
    super.key,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percent >= 0;
    final color = isPositive ? ObsidianTheme.accent : ObsidianTheme.lossRed;
    final arrow = isPositive ? '▲' : '▼';
    final sign = isPositive ? '+' : '';
    final label = '$arrow $sign${percent.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          color: color,
          letterSpacing: 0.04 * 10, // 0.04em
        ),
      ),
    );
  }
}

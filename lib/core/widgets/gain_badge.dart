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
    final bgColor = isPositive ? ObsidianTheme.gainGreenBg : ObsidianTheme.lossRedBg;
    final textColor = isPositive ? ObsidianTheme.gainGreen : ObsidianTheme.lossRed;
    final sign = isPositive ? '+' : '';
    final label = '$sign${percent.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

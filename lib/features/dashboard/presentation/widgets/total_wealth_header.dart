import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';

class TotalWealthHeader extends StatelessWidget {
  final WealthSummary summary;
  final bool isLoading;
  final bool isDesktop;

  const TotalWealthHeader({
    super.key,
    required this.summary,
    required this.isLoading,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(ObsidianTheme.radius);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ObsidianTheme.surface2,
        borderRadius: borderRadius,
        border: Border.all(
          color: ObsidianTheme.border,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Inner accent border
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: ObsidianTheme.accent.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '‪صافي الثروة · TOTAL WEALTH‬',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2 * 10,
                    color: ObsidianTheme.accent,
                  ),
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ObsidianTheme.accent,
                      ),
                    ),
                  )
                else ...[
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.formatEgp(summary.totalEgp),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isDesktop ? 42 : 36,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.8,
                          height: 1.05,
                          color: ObsidianTheme.text1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.formatUsd(summary.totalUsd),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ObsidianTheme.text2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Gain pill
                  _GainPill(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GainPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: ObsidianTheme.gainGreenBg,
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          border: Border.all(
            color: ObsidianTheme.gainGreen.withValues(alpha: 0.33),
            width: 1,
          ),
        ),
        child: Text(
          '+4.2% · 30D',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ObsidianTheme.gainGreen,
          ),
        ),
      ),
    );
  }
}

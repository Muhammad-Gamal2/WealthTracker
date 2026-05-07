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
    final borderRadius = BorderRadius.circular(isDesktop ? 20 : 18);
    final margin = isDesktop
        ? const EdgeInsets.all(28)
        : const EdgeInsets.only(left: 16, right: 16, top: 16);
    final padding = isDesktop
        ? const EdgeInsets.fromLTRB(32, 28, 32, 32)
        : const EdgeInsets.fromLTRB(22, 22, 22, 26);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: ObsidianTheme.accent.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Base linear gradient (145deg approx)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.5, -1),
                    end: Alignment(0.5, 1),
                    colors: [
                      Color(0xFF0D1628),
                      Color(0xFF101620),
                    ],
                  ),
                ),
              ),
            ),
            // Radial gradient 1: blue at 20% 70% (bottom-left area)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.6, 0.4),
                    radius: 0.55,
                    colors: [
                      const Color(0xFF5B9BFF).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Radial gradient 2: purple at 85% 10% (top-right area)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -0.8),
                    radius: 0.50,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Radial gradient 3: green at 60% 90% (bottom-center)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.2, 0.8),
                    radius: 0.40,
                    colors: [
                      const Color(0xFF34D399).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL WEALTH',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.08 * 11,
                      color: const Color(0xFFEEF2FF).withValues(alpha: 0.45),
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
                    Text(
                      CurrencyFormatter.formatEgp(summary.totalEgp),
                      style: GoogleFonts.dmMono(
                        fontSize: isDesktop ? 42 : 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        height: 1.05,
                        color: ObsidianTheme.text1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatUsd(summary.totalUsd),
                      style: GoogleFonts.dmMono(
                        fontSize: isDesktop ? 17 : 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFEEF2FF).withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                  SizedBox(height: isDesktop ? 24 : 20),
                  _CategoryChipRow(summary: summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  final WealthSummary summary;

  const _CategoryChipRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryChipData('Gold', ObsidianTheme.gold, summary.goldPercent),
      _CategoryChipData('Stocks', ObsidianTheme.green, summary.stocksPercent),
      _CategoryChipData('Liquidity', ObsidianTheme.cyan, summary.liquidityPercent),
      _CategoryChipData('Estate', ObsidianTheme.orange, summary.realEstatePercent),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) => _CategoryChip(data: cat)).toList(),
    );
  }
}

class _CategoryChipData {
  final String label;
  final Color color;
  final double percent;

  const _CategoryChipData(this.label, this.color, this.percent);
}

class _CategoryChip extends StatelessWidget {
  final _CategoryChipData data;

  const _CategoryChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ObsidianTheme.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x12FFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEEF2FF).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${data.percent.toStringAsFixed(1)}%',
            style: GoogleFonts.dmMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}

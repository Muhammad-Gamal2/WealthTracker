import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';

class CategorySummaryCard extends StatelessWidget {
  final String title;
  final String? titleAr;
  final double valueEgp;
  final double valueUsd;
  final double percent;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const CategorySummaryCard({
    super.key,
    required this.title,
    this.titleAr,
    required this.valueEgp,
    required this.valueUsd,
    required this.percent,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  static const Map<String, String> _arabicNames = {
    'Gold': 'ذهب',
    'Stocks': 'أسهم',
    'Liquidity': 'سيولة',
    'Real Estate': 'عقارات',
  };

  String get _displayAr => titleAr ?? _arabicNames[title] ?? title;

  @override
  Widget build(BuildContext context) {
    final accentBg = color.withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ObsidianTheme.radius),
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            color: ObsidianTheme.surface2,
            borderRadius: BorderRadius.circular(ObsidianTheme.radius),
            border: Border.all(
              color: ObsidianTheme.border,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withValues(alpha: 0.33),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _displayAr,
                style: GoogleFonts.reemKufi(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.cream,
                ),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  CurrencyFormatter.formatEgp(valueEgp),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ObsidianTheme.text1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  CurrencyFormatter.formatUsd(valueUsd),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: ObsidianTheme.text3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
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
            color: ObsidianTheme.card,
            borderRadius: BorderRadius.circular(ObsidianTheme.radius),
            border: Border(
              top: BorderSide(
                color: color.withValues(alpha: 0.33),
                width: 1,
              ),
              left: BorderSide(
                color: color.withValues(alpha: 0.20),
                width: 1,
              ),
              right: BorderSide(
                color: color.withValues(alpha: 0.20),
                width: 1,
              ),
              bottom: BorderSide(
                color: color.withValues(alpha: 0.20),
                width: 1,
              ),
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
                      borderRadius: BorderRadius.circular(10),
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
                      color: accentBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: GoogleFonts.dmMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ObsidianTheme.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatEgp(valueEgp),
                style: GoogleFonts.dmMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ObsidianTheme.text1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatUsd(valueUsd),
                style: GoogleFonts.dmMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: ObsidianTheme.text3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/gain_badge.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';

class RealEstateItemTile extends StatelessWidget {
  final RealEstateEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RealEstateItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatHeldDuration() {
    final diff = DateTime.now().difference(item.purchaseDate);
    final totalMonths = diff.inDays ~/ 30;
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    if (years > 0 && months > 0) return '${years}y ${months}m';
    if (years > 0) return '${years}y';
    if (months > 0) return '${months}m';
    return '${diff.inDays}d';
  }

  String _formatCompactEgp(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return 'EGP ${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return 'EGP ${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return CurrencyFormatter.formatEgp(value);
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = item.currentValueEgp;
    final gainPercent = item.gainPercent;

    return GlassCard(
      accent: ObsidianTheme.orange,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name + popup menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ObsidianTheme.orangeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.home_rounded,
                  color: ObsidianTheme.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    item.projectName,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ObsidianTheme.text1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              // Popup menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: ObsidianTheme.text3, size: 20),
                color: ObsidianTheme.surface2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ObsidianTheme.radius),
                  side: BorderSide(color: ObsidianTheme.border),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      'Edit',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: ObsidianTheme.text1,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: ObsidianTheme.lossRed,
                      ),
                    ),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stat chips: PURCHASED, ANNUAL RATE, HELD
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStatChip('PURCHASED', _formatCompactEgp(item.purchaseAmountEgp)),
              _buildStatChip('ANNUAL RATE', '${item.annualAppreciationPercent.toStringAsFixed(1)}%'),
              _buildStatChip('HELD', _formatHeldDuration()),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Container(
            height: 1,
            color: ObsidianTheme.border,
          ),
          const SizedBox(height: 14),
          // Bottom: Current Value + GainBadge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Value',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ObsidianTheme.text3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatEgp(currentValue),
                    style: GoogleFonts.dmMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ObsidianTheme.text1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: gainPercent >= 0
                      ? ObsidianTheme.gainGreenBg
                      : ObsidianTheme.lossRedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${gainPercent >= 0 ? '+' : ''}${gainPercent.toStringAsFixed(1)}%',
                  style: GoogleFonts.dmMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: gainPercent >= 0
                        ? ObsidianTheme.gainGreen
                        : ObsidianTheme.lossRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text3,
            letterSpacing: 0.06 * 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmMono(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ObsidianTheme.text2,
          ),
        ),
      ],
    );
  }
}

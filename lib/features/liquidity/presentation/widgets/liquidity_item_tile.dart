import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';

class LiquidityItemTile extends StatelessWidget {
  final LiquidityEntity item;
  final double egpValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LiquidityItemTile({
    super.key,
    required this.item,
    required this.egpValue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accent: ObsidianTheme.cyan,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ObsidianTheme.cyanBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop,
                color: ObsidianTheme.cyan,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label.isEmpty ? 'Cash' : item.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ObsidianTheme.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatUsd(item.amountUsd),
                    style: GoogleFonts.dmMono(
                      fontSize: 12,
                      color: ObsidianTheme.text3,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatEgp(egpValue),
              style: GoogleFonts.dmMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ObsidianTheme.text1,
              ),
            ),
            const SizedBox(width: 4),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';

class GoldItemTile extends StatelessWidget {
  final GoldEntity item;
  final double valueEgp;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoldItemTile({
    super.key,
    required this.item,
    required this.valueEgp,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPurchasePrice = item.purchasePricePerGram > 0;
    final purchaseCost = item.totalPurchaseCost;
    final gainLoss = hasPurchasePrice && valueEgp > 0
        ? valueEgp - purchaseCost
        : null;
    final gainPercent = hasPurchasePrice && purchaseCost > 0 && valueEgp > 0
        ? ((valueEgp - purchaseCost) / purchaseCost) * 100
        : null;

    return GlassCard(
      accent: ObsidianTheme.gold,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ObsidianTheme.goldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.savings,
                color: ObsidianTheme.gold,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label.isEmpty ? '${item.karat}K Gold' : item.label,
                    style: GoogleFonts.reemKufi(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ObsidianTheme.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.karat}K · ${CurrencyFormatter.formatGrams(item.weightGrams)}',
                    style: GoogleFonts.reemKufi(
                      fontSize: 12,
                      color: ObsidianTheme.text3,
                    ),
                  ),
                  if (hasPurchasePrice) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Cost: ${CurrencyFormatter.formatEgp(purchaseCost)}',
                      style: GoogleFonts.reemKufi(
                        fontSize: 11,
                        color: ObsidianTheme.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatEgp(valueEgp),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ObsidianTheme.text1,
                  ),
                ),
                if (gainPercent != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.formatPercent(gainPercent),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: gainLoss! >= 0
                          ? ObsidianTheme.green
                          : ObsidianTheme.lossRed,
                    ),
                  ),
                ],
              ],
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
                    style: GoogleFonts.reemKufi(
                      fontSize: 14,
                      color: ObsidianTheme.text1,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: GoogleFonts.reemKufi(
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

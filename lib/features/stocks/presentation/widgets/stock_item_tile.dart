import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/gain_badge.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';

class StockItemTile extends StatelessWidget {
  final StockEntity item;
  final double currentPrice;
  final double totalEgp;
  final double gainPercent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StockItemTile({
    super.key,
    required this.item,
    required this.currentPrice,
    required this.totalEgp,
    required this.gainPercent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEgx = item.isEgx;
    final accentColor = isEgx ? ObsidianTheme.cyan : ObsidianTheme.green;
    final accentBg = isEgx ? ObsidianTheme.cyanBg : ObsidianTheme.greenBg;
    final currencyLabel = isEgx ? 'EGP' : 'USD';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Leading: circle with market label
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                item.market,
                style: GoogleFonts.reemKufi(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Center: symbol, company name, shares info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.symbol,
                        style: GoogleFonts.reemKufi(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.text1,
                        ),
                      ),
                      if (item.name.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.name,
                            style: GoogleFonts.reemKufi(
                              fontSize: 11,
                              color: ObsidianTheme.text3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${CurrencyFormatter.formatNumber(item.quantity)} shares \u00b7 $currencyLabel ${currentPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.reemKufi(
                      fontSize: 11,
                      color: ObsidianTheme.text3,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing: total EGP + GainBadge + menu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  CurrencyFormatter.formatEgp(totalEgp),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ObsidianTheme.text1,
                  ),
                ),
                const SizedBox(height: 4),
                GainBadge(percent: gainPercent),
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

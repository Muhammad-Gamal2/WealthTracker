import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/core/widgets/section_title.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_signals.dart';
import 'package:wealth_tracker/features/gold/presentation/widgets/add_gold_dialog.dart';
import 'package:wealth_tracker/features/gold/presentation/widgets/gold_item_tile.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  @override
  void initState() {
    super.initState();
    loadGoldItems();
    loadGoldPrices();
  }

  Future<void> _refresh() async {
    await loadGoldItems();
    await loadGoldPrices(forceRefresh: true);
  }

  double _itemValue(GoldEntity item, PriceSnapshot? prices) {
    if (prices == null) return 0;
    return item.weightGrams * prices.priceForKarat(item.karat);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: ObsidianTheme.headerBg,
            border: Border(
              bottom: BorderSide(color: ObsidianTheme.border),
            ),
          ),
          child: Row(
            children: [
              Text(
                'الذهب',
                style: GoogleFonts.reemKufi(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.text1,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: ObsidianTheme.text2, size: 22),
                onPressed: _refresh,
                tooltip: 'Refresh prices',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Watch((context) {
            if (goldLoadingSignal.value) {
              return const Center(
                child: CircularProgressIndicator(color: ObsidianTheme.gold),
              );
            }
            if (goldErrorSignal.value != null) {
              return Center(
                child: Text(
                  'Error: ${goldErrorSignal.value}',
                  style: GoogleFonts.reemKufi(
                    fontSize: 13,
                    color: ObsidianTheme.lossRed,
                  ),
                ),
              );
            }

            final items = goldItemsSignal.value;
            final prices = goldPricesSignal.value;
            final totalEgp = items.fold(0.0, (sum, i) => sum + _itemValue(i, prices));

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1100;

                Widget content = Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // Price header card
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 24 : 16,
                              16,
                              isDesktop ? 24 : 16,
                              8,
                            ),
                            child: _buildPriceHeader(prices),
                          ),
                        ),
                        // Section title
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: SectionTitle(
                              title: 'الممتلكات · Holdings',
                              right: Text(
                                CurrencyFormatter.formatEgp(totalEgp),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ObsidianTheme.gold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Items list or empty state
                        if (items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد عناصر ذهبية بعد.\nاضغط + لإضافة واحد.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.reemKufi(
                                  fontSize: 13,
                                  color: ObsidianTheme.text3,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 24 : 16,
                              0,
                              isDesktop ? 24 : 16,
                              100,
                            ),
                            sliver: SliverList.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) => GoldItemTile(
                                item: items[i],
                                valueEgp: _itemValue(items[i], prices),
                                onEdit: () =>
                                    _showAddEditSheet(context, items[i]),
                                onDelete: () =>
                                    _confirmDelete(context, items[i]),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // FAB
                    Positioned(
                      right: isDesktop ? 24 : 16,
                      bottom: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(ObsidianTheme.radius),
                          boxShadow: [
                            BoxShadow(
                              color: ObsidianTheme.accent.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          heroTag: 'gold_fab',
                          onPressed: () => _showAddEditSheet(context, null),
                          backgroundColor: ObsidianTheme.accent,
                          foregroundColor: ObsidianTheme.bg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ObsidianTheme.radius),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                  ],
                );

                if (isDesktop) {
                  content = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: content,
                    ),
                  );
                }

                return content;
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriceHeader(PriceSnapshot? prices) {
    if (prices == null) {
      return const SizedBox.shrink();
    }
    final p = prices;
    return GlassCard(
      accent: ObsidianTheme.gold,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أسعار اليوم · per gram',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ObsidianTheme.text2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _karatChip('24K', p.goldPrice24k),
              _karatChip('21K', p.goldPrice21k),
              _karatChip('18K', p.goldPrice18k),
            ],
          ),
          if (p.isStale) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.warning_amber,
                    size: 14, color: ObsidianTheme.lossRed),
                const SizedBox(width: 4),
                Text(
                  'Prices may be outdated',
                  style: GoogleFonts.reemKufi(
                    fontSize: 11,
                    color: ObsidianTheme.lossRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _karatChip(String karat, double price) {
    return Column(
      children: [
        Text(
          karat,
          style: GoogleFonts.reemKufi(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.gold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatEgp(price),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ObsidianTheme.text1,
          ),
        ),
      ],
    );
  }

  void _showAddEditSheet(BuildContext context, GoldEntity? existing) {
    showAddGoldSheet(context, existing: existing);
  }

  void _confirmDelete(BuildContext context, GoldEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ObsidianTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          side: BorderSide(color: ObsidianTheme.border),
        ),
        title: Text(
          'إزالة العنصر',
          style: GoogleFonts.amiri(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
        ),
        content: Text(
          'Remove "${item.label}"?',
          style: GoogleFonts.reemKufi(
            fontSize: 14,
            color: ObsidianTheme.text2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.reemKufi(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ObsidianTheme.text2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteGoldItem(item.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.reemKufi(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ObsidianTheme.lossRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

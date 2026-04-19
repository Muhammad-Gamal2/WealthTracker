import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/core/widgets/section_title.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_signals.dart';
import 'package:wealth_tracker/features/stocks/presentation/widgets/add_stock_dialog.dart';
import 'package:wealth_tracker/features/stocks/presentation/widgets/stock_item_tile.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  PriceSnapshot? _prices;

  @override
  void initState() {
    super.initState();
    loadStockItems();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final items = stockItemsSignal.value;
    final p = await sl<PriceUpdateService>().getLatestPrices(
      stockApiSymbols: items.map((s) => s.apiSymbol).toList(),
    );
    if (mounted) {
      setState(() => _prices = p);
    }
  }

  Future<void> _refresh() async {
    await loadStockItems();
    await _loadPrices();
  }

  double _itemTotalEgp(StockEntity item) {
    if (_prices == null) return 0;
    final price = _prices!.stockPrices[item.apiSymbol] ?? 0;
    return item.isEgx
        ? item.quantity * price
        : item.quantity * price * _prices!.usdToEgpRate;
  }

  double _itemCurrentPrice(StockEntity item) {
    if (_prices == null) return 0;
    return _prices!.stockPrices[item.apiSymbol] ?? 0;
  }

  double _itemGainPercent(StockEntity item) {
    if (_prices == null) return 0;
    final currentPrice = _prices!.stockPrices[item.apiSymbol] ?? 0;
    if (item.purchasePrice <= 0) return 0;
    return ((currentPrice - item.purchasePrice) / item.purchasePrice) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xB807090F),
            border: Border(
              bottom: BorderSide(color: ObsidianTheme.border),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Stocks',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ObsidianTheme.text1,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh,
                    color: ObsidianTheme.text2, size: 22),
                onPressed: _refresh,
                tooltip: 'Refresh prices',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Watch((context) {
            if (stocksLoadingSignal.value) {
              return const Center(
                child:
                    CircularProgressIndicator(color: ObsidianTheme.green),
              );
            }
            if (stocksErrorSignal.value != null) {
              return Center(
                child: Text(
                  'Error: ${stocksErrorSignal.value}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: ObsidianTheme.lossRed,
                  ),
                ),
              );
            }

            final items = stockItemsSignal.value;
            final totalEgp =
                items.fold(0.0, (sum, i) => sum + _itemTotalEgp(i));

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1100;

                Widget content = Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // Exchange rate + portfolio header card
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 24 : 16,
                              16,
                              isDesktop ? 24 : 16,
                              8,
                            ),
                            child: _buildHeaderCard(items),
                          ),
                        ),
                        // Section title
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8, bottom: 12),
                            child: SectionTitle(
                              title: 'Holdings',
                              right: Text(
                                '${items.length} stock${items.length == 1 ? '' : 's'}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ObsidianTheme.text3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Items or empty state
                        if (items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No stocks yet.\nTap + to add one.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
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
                              itemBuilder: (context, i) {
                                final item = items[i];
                                return StockItemTile(
                                  item: item,
                                  currentPrice: _itemCurrentPrice(item),
                                  totalEgp: _itemTotalEgp(item),
                                  gainPercent: _itemGainPercent(item),
                                  onEdit: () =>
                                      _showAddEditSheet(context, item),
                                  onDelete: () =>
                                      _confirmDelete(context, item),
                                );
                              },
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
                              color: ObsidianTheme.accent
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed: () =>
                              _showAddEditSheet(context, null),
                          backgroundColor: ObsidianTheme.accent,
                          foregroundColor: ObsidianTheme.bg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ObsidianTheme.radius),
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

  Widget _buildHeaderCard(List<StockEntity> items) {
    final rate = _prices?.usdToEgpRate ?? 0;
    final totalEgp = items.fold(0.0, (sum, i) => sum + _itemTotalEgp(i));
    final totalUsd = rate > 0 ? totalEgp / rate : 0.0;

    return GlassCard(
      accent: ObsidianTheme.green,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exchange rate on left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Rate',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ObsidianTheme.text2,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '1 USD = EGP ',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: ObsidianTheme.text2,
                        ),
                      ),
                      TextSpan(
                        text: rate > 0
                            ? rate.toStringAsFixed(2)
                            : '--',
                        style: GoogleFonts.dmMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.green,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_prices?.isStale ?? false) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          size: 14, color: ObsidianTheme.lossRed),
                      const SizedBox(width: 4),
                      Text(
                        'Prices may be outdated',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: ObsidianTheme.lossRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Portfolio total on right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Portfolio Total',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.text2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatEgp(totalEgp),
                style: GoogleFonts.dmMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ObsidianTheme.text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatUsd(totalUsd),
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  color: ObsidianTheme.text3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditSheet(BuildContext context, StockEntity? existing) {
    showAddStockSheet(context, existing: existing);
  }

  void _confirmDelete(BuildContext context, StockEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ObsidianTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          side: const BorderSide(color: ObsidianTheme.border),
        ),
        title: Text(
          'Delete Stock',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
        ),
        content: Text(
          'Remove "${item.symbol}"?',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: ObsidianTheme.text2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ObsidianTheme.text2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteStockItem(item.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
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

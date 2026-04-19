import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/core/widgets/section_title.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_signals.dart';
import 'package:wealth_tracker/features/liquidity/presentation/widgets/add_liquidity_dialog.dart';
import 'package:wealth_tracker/features/liquidity/presentation/widgets/liquidity_item_tile.dart';

class LiquidityScreen extends StatefulWidget {
  const LiquidityScreen({super.key});

  @override
  State<LiquidityScreen> createState() => _LiquidityScreenState();
}

class _LiquidityScreenState extends State<LiquidityScreen> {
  PriceSnapshot? _prices;

  @override
  void initState() {
    super.initState();
    loadLiquidityItems();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final p = await sl<PriceUpdateService>()
        .getLatestPrices(stockApiSymbols: const []);
    if (mounted) {
      setState(() => _prices = p);
    }
  }

  Future<void> _refresh() async {
    await loadLiquidityItems();
    await _loadPrices();
  }

  double get _usdToEgpRate => _prices?.usdToEgpRate ?? 1;

  double _itemEgpValue(LiquidityEntity item) {
    return item.amountUsd * _usdToEgpRate;
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
                'Liquidity',
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
                tooltip: 'Refresh rates',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Watch((context) {
            if (liquidityLoadingSignal.value) {
              return const Center(
                child: CircularProgressIndicator(color: ObsidianTheme.cyan),
              );
            }
            if (liquidityErrorSignal.value != null) {
              return Center(
                child: Text(
                  'Error: ${liquidityErrorSignal.value}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: ObsidianTheme.lossRed,
                  ),
                ),
              );
            }

            final items = liquidityItemsSignal.value;
            final totalUsd =
                items.fold(0.0, (sum, i) => sum + i.amountUsd);
            final totalEgp = totalUsd * _usdToEgpRate;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1100;

                Widget content = Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // Exchange rate header card
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 24 : 16,
                              16,
                              isDesktop ? 24 : 16,
                              8,
                            ),
                            child: _buildRateHeader(totalUsd, totalEgp),
                          ),
                        ),
                        // Section title
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: SectionTitle(
                              title: 'Cash Accounts',
                              right: Text(
                                CurrencyFormatter.formatEgp(totalEgp),
                                style: GoogleFonts.dmMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ObsidianTheme.cyan,
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
                                'No cash accounts yet.\nTap + to add one.',
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
                              itemBuilder: (context, i) => LiquidityItemTile(
                                item: items[i],
                                egpValue: _itemEgpValue(items[i]),
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
                              color:
                                  ObsidianTheme.accent.withValues(alpha: 0.4),
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

  Widget _buildRateHeader(double totalUsd, double totalEgp) {
    if (_prices == null) {
      return const SizedBox.shrink();
    }
    final p = _prices!;
    return GlassCard(
      accent: ObsidianTheme.cyan,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
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
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '1 USD = EGP ',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ObsidianTheme.text1,
                        ),
                      ),
                      TextSpan(
                        text: CurrencyFormatter.formatNumber(p.usdToEgpRate),
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                if (p.isStale) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          size: 14, color: ObsidianTheme.lossRed),
                      const SizedBox(width: 4),
                      Text(
                        'Rate may be outdated',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.text3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatUsd(totalUsd),
                style: GoogleFonts.dmMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ObsidianTheme.text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatEgp(totalEgp),
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ObsidianTheme.text2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditSheet(BuildContext context, LiquidityEntity? existing) {
    showAddLiquiditySheet(context, existing: existing);
  }

  void _confirmDelete(BuildContext context, LiquidityEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ObsidianTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          side: const BorderSide(color: ObsidianTheme.border),
        ),
        title: Text(
          'Delete Item',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
        ),
        content: Text(
          'Remove "${item.label}"?',
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
              deleteLiquidityItem(item.id);
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

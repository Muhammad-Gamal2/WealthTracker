import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/section_title.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_signals.dart';
import 'package:wealth_tracker/features/real_estate/presentation/widgets/add_real_estate_dialog.dart';
import 'package:wealth_tracker/features/real_estate/presentation/widgets/real_estate_item_tile.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  @override
  void initState() {
    super.initState();
    loadRealEstateItems();
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
                'العقارات',
                style: GoogleFonts.reemKufi(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ObsidianTheme.text1,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh,
                    color: ObsidianTheme.text2, size: 22),
                onPressed: () => loadRealEstateItems(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Watch((context) {
            if (realEstateLoadingSignal.value) {
              return const Center(
                child:
                    CircularProgressIndicator(color: ObsidianTheme.orange),
              );
            }
            if (realEstateErrorSignal.value != null) {
              return Center(
                child: Text(
                  'Error: ${realEstateErrorSignal.value}',
                  style: GoogleFonts.reemKufi(
                    fontSize: 13,
                    color: ObsidianTheme.lossRed,
                  ),
                ),
              );
            }

            final items = realEstateItemsSignal.value;
            final totalCurrent =
                items.fold(0.0, (sum, i) => sum + i.currentValueEgp);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1100;

                Widget content = Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // Section title with total
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 20, bottom: 12),
                            child: SectionTitle(
                              title: 'الممتلكات · Properties',
                              right: Text(
                                CurrencyFormatter.formatEgp(totalCurrent),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ObsidianTheme.text2,
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
                                'لا توجد عقارات بعد.\nاضغط + لإضافة واحد.',
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
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final item = items[i];
                                return RealEstateItemTile(
                                  item: item,
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
                          heroTag: 'real_estate_fab',
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

  void _showAddEditSheet(
      BuildContext context, RealEstateEntity? existing) {
    showAddRealEstateSheet(context, existing: existing);
  }

  void _confirmDelete(BuildContext context, RealEstateEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ObsidianTheme.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianTheme.radius),
          side: BorderSide(color: ObsidianTheme.border),
        ),
        title: Text(
          'إزالة العقار',
          style: GoogleFonts.amiri(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ObsidianTheme.text1,
          ),
        ),
        content: Text(
          'Remove "${item.projectName}"?',
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
              deleteRealEstateItem(item.id);
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

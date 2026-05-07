import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/widgets/glass_card.dart';
import 'package:wealth_tracker/features/dashboard/presentation/dashboard_signals.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/category_summary_card.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/total_wealth_header.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/wealth_line_chart.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/wealth_pie_chart.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final summary = wealthSummarySignal.value;
      final snapshots = snapshotsSignal.value;
      final isLoading = dashboardLoadingSignal.value;
      final error = dashboardErrorSignal.value;
      final width = MediaQuery.of(context).size.width;
      final isDesktop = width > 1100;

      if (isDesktop) {
        return _buildDesktopLayout(
          context,
          summary: summary,
          snapshots: snapshots,
          isLoading: isLoading,
          error: error,
        );
      } else {
        return _buildMobileLayout(
          context,
          summary: summary,
          snapshots: snapshots,
          isLoading: isLoading,
          error: error,
        );
      }
    });
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required summary,
    required List snapshots,
    required bool isLoading,
    required String? error,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TotalWealthHeader(
                  summary: summary,
                  isLoading: isLoading,
                  isDesktop: true,
                ),
                if (error != null) _buildErrorCard(context, error),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'CATEGORIES'),
                          const SizedBox(height: 12),
                          _buildCategoryGrid(context, summary),
                          const SizedBox(height: 24),
                          _buildHistorySection(context, snapshots),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right column
                    SizedBox(
                      width: 320,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(title: 'BREAKDOWN'),
                          const SizedBox(height: 12),
                          GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 18,
                            ),
                            child: WealthPieChart(
                              summary: summary,
                              onSectionTap: (index) =>
                                  _navigateToCategory(context, index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required summary,
    required List snapshots,
    required bool isLoading,
    required String? error,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8, top: 8),
            child: Row(
              children: [
                Text(
                  'Dashboard',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ObsidianTheme.text1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.settings_outlined,
                      color: ObsidianTheme.text2, size: 22),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.settings),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
          TotalWealthHeader(
            summary: summary,
            isLoading: isLoading,
            isDesktop: false,
          ),
          if (error != null) _buildErrorCard(context, error),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(title: 'BREAKDOWN'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),
              child: WealthPieChart(
                summary: summary,
                onSectionTap: (index) =>
                    _navigateToCategory(context, index),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(title: 'CATEGORIES'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCategoryGrid(context, summary),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHistorySection(context, snapshots),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        accent: ObsidianTheme.lossRed,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: ObsidianTheme.lossRed, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update error',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ObsidianTheme.lossRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    error,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: ObsidianTheme.text3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, summary) {
    final cards = _buildCategoryCards(context, summary);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: cards,
    );
  }

  Widget _buildHistorySection(BuildContext context, List snapshots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(title: 'HISTORY'),
            _PeriodSelector(),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
          child: WealthLineChart(snapshots: snapshots.cast()),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryCards(BuildContext context, summary) {
    return [
      CategorySummaryCard(
        title: 'Gold',
        valueEgp: summary.goldValueEgp,
        valueUsd: summary.goldValueUsd,
        percent: summary.goldPercent,
        color: ObsidianTheme.gold,
        icon: Icons.savings,
        onTap: () => _navigateToCategory(context, 0),
      ),
      CategorySummaryCard(
        title: 'Stocks',
        valueEgp: summary.stocksValueEgp,
        valueUsd: summary.stocksValueUsd,
        percent: summary.stocksPercent,
        color: ObsidianTheme.green,
        icon: Icons.trending_up,
        onTap: () => _navigateToCategory(context, 1),
      ),
      CategorySummaryCard(
        title: 'Liquidity',
        valueEgp: summary.liquidityValueEgp,
        valueUsd: summary.liquidityValueUsd,
        percent: summary.liquidityPercent,
        color: ObsidianTheme.cyan,
        icon: Icons.water_drop,
        onTap: () => _navigateToCategory(context, 2),
      ),
      CategorySummaryCard(
        title: 'Real Estate',
        valueEgp: summary.realEstateValueEgp,
        valueUsd: summary.realEstateValueUsd,
        percent: summary.realEstatePercent,
        color: ObsidianTheme.orange,
        icon: Icons.home_work,
        onTap: () => _navigateToCategory(context, 3),
      ),
    ];
  }

  void _navigateToCategory(BuildContext context, int index) {
    // index 0=gold, 1=stocks, 2=liquidity, 3=realEstate
    // tab indices: 1=gold, 2=stocks, 3=liquidity, 4=realEstate
    if (widget.onNavigateToTab != null && index >= 0 && index < 4) {
      widget.onNavigateToTab!(index + 1);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 11,
        color: ObsidianTheme.text3,
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final period = selectedPeriodSignal.value;
      final periods = [
        const _PeriodOption(30, '30D'),
        const _PeriodOption(90, '90D'),
        const _PeriodOption(365, '1Y'),
        const _PeriodOption(0, 'All'),
      ];

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isSelected = period == p.value;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: GestureDetector(
              onTap: () {
                selectedPeriodSignal.value = p.value;
                loadSnapshots();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ObsidianTheme.accentBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? ObsidianTheme.accent.withValues(alpha: 0.3)
                        : ObsidianTheme.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  p.label,
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? ObsidianTheme.accent
                        : ObsidianTheme.text3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _PeriodOption {
  final int value;
  final String label;
  const _PeriodOption(this.value, this.label);
}

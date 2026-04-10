import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/constants/app_constants.dart';
import 'package:wealth_tracker/features/dashboard/presentation/dashboard_signals.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/category_summary_card.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/total_wealth_header.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/wealth_line_chart.dart';
import 'package:wealth_tracker/features/dashboard/presentation/widgets/wealth_pie_chart.dart';
import 'package:wealth_tracker/routing/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WealthTracker'),
        actions: [
          Watch((context) => dashboardLoadingSignal.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh prices',
                  onPressed: () => refreshDashboard(forceRefresh: true),
                )),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: Watch((context) {
        final summary = wealthSummarySignal.value;
        final snapshots = snapshotsSignal.value;
        final isLoading = dashboardLoadingSignal.value;
        final error = dashboardErrorSignal.value;

        return RefreshIndicator(
          onRefresh: () => refreshDashboard(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TotalWealthHeader(
                  summary: summary,
                  isLoading: isLoading,
                  onRefresh: () => refreshDashboard(forceRefresh: true),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(Icons.warning,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                        title: Text('Update error',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer)),
                        subtitle: Text(error,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                                fontSize: 11)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WealthPieChart(
                    summary: summary,
                    onSectionTap: (index) {
                      final routes = [
                        AppRouter.gold,
                        AppRouter.stocks,
                        AppRouter.liquidity,
                        AppRouter.realEstate,
                      ];
                      if (index < routes.length) {
                        Navigator.pushNamed(context, routes[index]);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isWide
                      ? GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: _buildCategoryCards(context, summary),
                        )
                      : Column(
                          children: _buildCategoryCards(context, summary)
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: c,
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('History',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      _PeriodSelector(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: WealthLineChart(snapshots: snapshots),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _BottomNav(),
    );
  }

  List<Widget> _buildCategoryCards(
      BuildContext context, summary) {
    return [
      CategorySummaryCard(
        title: 'Gold',
        valueEgp: summary.goldValueEgp,
        valueUsd: summary.goldValueUsd,
        percent: summary.goldPercent,
        color: const Color(0xFFFFD700),
        icon: Icons.savings,
        onTap: () => Navigator.pushNamed(context, AppRouter.gold),
      ),
      CategorySummaryCard(
        title: 'Stocks',
        valueEgp: summary.stocksValueEgp,
        valueUsd: summary.stocksValueUsd,
        percent: summary.stocksPercent,
        color: const Color(0xFF4CAF50),
        icon: Icons.trending_up,
        onTap: () => Navigator.pushNamed(context, AppRouter.stocks),
      ),
      CategorySummaryCard(
        title: 'Liquidity',
        valueEgp: summary.liquidityValueEgp,
        valueUsd: summary.liquidityValueUsd,
        percent: summary.liquidityPercent,
        color: const Color(0xFF2196F3),
        icon: Icons.water_drop,
        onTap: () => Navigator.pushNamed(context, AppRouter.liquidity),
      ),
      CategorySummaryCard(
        title: 'Real Estate',
        valueEgp: summary.realEstateValueEgp,
        valueUsd: summary.realEstateValueUsd,
        percent: summary.realEstatePercent,
        color: const Color(0xFFFF5722),
        icon: Icons.home_work,
        onTap: () => Navigator.pushNamed(context, AppRouter.realEstate),
      ),
    ];
  }
}

class _PeriodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final period = selectedPeriodSignal.value;
      return SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 30, label: Text('30D')),
          ButtonSegment(value: 90, label: Text('90D')),
          ButtonSegment(value: 365, label: Text('1Y')),
          ButtonSegment(value: 0, label: Text('All')),
        ],
        selected: {period},
        onSelectionChanged: (s) {
          selectedPeriodSignal.value = s.first;
          loadSnapshots();
        },
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    });
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.savings), label: 'Gold'),
        NavigationDestination(
            icon: Icon(Icons.trending_up), label: 'Stocks'),
        NavigationDestination(
            icon: Icon(Icons.water_drop), label: 'Liquidity'),
        NavigationDestination(icon: Icon(Icons.home_work), label: 'Estate'),
      ],
      onDestinationSelected: (i) {
        final routes = [
          AppRouter.dashboard,
          AppRouter.gold,
          AppRouter.stocks,
          AppRouter.liquidity,
          AppRouter.realEstate,
        ];
        if (ModalRoute.of(context)?.settings.name != routes[i]) {
          Navigator.pushReplacementNamed(context, routes[i]);
        }
      },
      selectedIndex: _currentIndex(context),
    );
  }

  int _currentIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    const routes = [
      AppRouter.dashboard,
      AppRouter.gold,
      AppRouter.stocks,
      AppRouter.liquidity,
      AppRouter.realEstate,
    ];
    return routes.indexOf(route ?? AppRouter.dashboard).clamp(0, 4);
  }
}

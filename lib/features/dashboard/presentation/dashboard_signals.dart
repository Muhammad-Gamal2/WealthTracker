import 'package:signals_flutter/signals_flutter.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';
import 'package:wealth_tracker/features/dashboard/domain/wealth_repository.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_signals.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_signals.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_signals.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_signals.dart';

final wealthSummarySignal = signal<WealthSummary>(WealthSummary.empty);
final snapshotsSignal = signal<List<SnapshotEntity>>([]);
final dashboardLoadingSignal = signal<bool>(false);
final dashboardErrorSignal = signal<String?>(null);
final selectedPeriodSignal = signal<int>(30); // days

Future<void> refreshDashboard({bool forceRefresh = false}) async {
  dashboardLoadingSignal.value = true;
  dashboardErrorSignal.value = null;
  try {
    final repo = sl<WealthRepository>();
    final summary = await repo.getWealthSummary();
    wealthSummarySignal.value = summary;

    // Save today's snapshot
    await repo.saveSnapshot(summary);

    // Reload snapshots for chart
    await loadSnapshots();

    // Refresh all item lists
    await Future.wait([
      loadGoldItems(),
      loadStockItems(),
      loadLiquidityItems(),
      loadRealEstateItems(),
    ]);
  } catch (e) {
    dashboardErrorSignal.value = e.toString();
  } finally {
    dashboardLoadingSignal.value = false;
  }
}

Future<void> loadSnapshots() async {
  final period = selectedPeriodSignal.value;
  final snapshots = await sl<WealthRepository>().getSnapshots(
    lastNDays: period == 0 ? null : period,
  );
  snapshotsSignal.value = snapshots;
}

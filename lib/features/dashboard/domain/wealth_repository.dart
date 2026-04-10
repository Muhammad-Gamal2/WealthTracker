import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';

abstract class WealthRepository {
  Future<WealthSummary> getWealthSummary();
  Future<List<SnapshotEntity>> getSnapshots({int? lastNDays});
  Future<void> saveSnapshot(WealthSummary summary);
}

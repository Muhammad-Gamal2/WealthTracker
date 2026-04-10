import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wealth_tracker/core/constants/app_constants.dart';

part 'app_database.g.dart';

// ─── Tables ────────────────────────────────────────────────────

class GoldItems extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withDefault(const Constant(''))();
  RealColumn get weightGrams => real()();
  IntColumn get karat => integer().withDefault(const Constant(24))();
  DateTimeColumn get dateAdded => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockItems extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  RealColumn get quantity => real()();
  RealColumn get purchasePrice => real()();
  TextColumn get market => text().withDefault(const Constant('EGX'))();
  TextColumn get currency => text().withDefault(const Constant('EGP'))();
  DateTimeColumn get dateAdded => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LiquidityItems extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withDefault(const Constant(''))();
  RealColumn get amountUsd => real()();
  DateTimeColumn get dateAdded => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RealEstateItems extends Table {
  TextColumn get id => text()();
  TextColumn get projectName => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  RealColumn get purchaseAmountEgp => real()();
  RealColumn get annualAppreciationPercent => real()();
  DateTimeColumn get dateAdded => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PriceCacheEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fetchDate => dateTime()();
  RealColumn get goldPrice24k => real().withDefault(const Constant(0))();
  RealColumn get goldPrice22k => real().withDefault(const Constant(0))();
  RealColumn get goldPrice21k => real().withDefault(const Constant(0))();
  RealColumn get goldPrice18k => real().withDefault(const Constant(0))();
  RealColumn get usdToEgpRate => real().withDefault(const Constant(0))();
}

class StockPriceCacheEntries extends Table {
  TextColumn get symbol => text()();
  RealColumn get price => real()();
  TextColumn get currency => text().withDefault(const Constant('EGP'))();
  DateTimeColumn get fetchDate => dateTime()();

  @override
  Set<Column> get primaryKey => {symbol};
}

class DailySnapshots extends Table {
  TextColumn get date => text()();
  RealColumn get totalValueEgp => real()();
  RealColumn get totalValueUsd => real()();
  RealColumn get goldValueEgp => real()();
  RealColumn get stocksValueEgp => real()();
  RealColumn get liquidityValueEgp => real()();
  RealColumn get realEstateValueEgp => real()();

  @override
  Set<Column> get primaryKey => {date};
}

class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  String get tableName => 'app_settings';

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Database ──────────────────────────────────────────────────

@DriftDatabase(tables: [
  GoldItems,
  StockItems,
  LiquidityItems,
  RealEstateItems,
  PriceCacheEntries,
  StockPriceCacheEntries,
  DailySnapshots,
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ── Gold CRUD ──

  Future<List<GoldItem>> getAllGoldItems() => select(goldItems).get();

  Stream<List<GoldItem>> watchAllGoldItems() => select(goldItems).watch();

  Future<int> insertGoldItem(GoldItemsCompanion entry) =>
      into(goldItems).insert(entry);

  Future<bool> updateGoldItem(GoldItemsCompanion entry) =>
      update(goldItems).replace(entry);

  Future<int> deleteGoldItem(String id) =>
      (delete(goldItems)..where((t) => t.id.equals(id))).go();

  // ── Stock CRUD ──

  Future<List<StockItem>> getAllStockItems() => select(stockItems).get();

  Stream<List<StockItem>> watchAllStockItems() => select(stockItems).watch();

  Future<int> insertStockItem(StockItemsCompanion entry) =>
      into(stockItems).insert(entry);

  Future<bool> updateStockItem(StockItemsCompanion entry) =>
      update(stockItems).replace(entry);

  Future<int> deleteStockItem(String id) =>
      (delete(stockItems)..where((t) => t.id.equals(id))).go();

  // ── Liquidity CRUD ──

  Future<List<LiquidityItem>> getAllLiquidityItems() =>
      select(liquidityItems).get();

  Stream<List<LiquidityItem>> watchAllLiquidityItems() =>
      select(liquidityItems).watch();

  Future<int> insertLiquidityItem(LiquidityItemsCompanion entry) =>
      into(liquidityItems).insert(entry);

  Future<bool> updateLiquidityItem(LiquidityItemsCompanion entry) =>
      update(liquidityItems).replace(entry);

  Future<int> deleteLiquidityItem(String id) =>
      (delete(liquidityItems)..where((t) => t.id.equals(id))).go();

  // ── Real Estate CRUD ──

  Future<List<RealEstateItem>> getAllRealEstateItems() =>
      select(realEstateItems).get();

  Stream<List<RealEstateItem>> watchAllRealEstateItems() =>
      select(realEstateItems).watch();

  Future<int> insertRealEstateItem(RealEstateItemsCompanion entry) =>
      into(realEstateItems).insert(entry);

  Future<bool> updateRealEstateItem(RealEstateItemsCompanion entry) =>
      update(realEstateItems).replace(entry);

  Future<int> deleteRealEstateItem(String id) =>
      (delete(realEstateItems)..where((t) => t.id.equals(id))).go();

  // ── Price Cache ──

  Future<PriceCacheEntry?> getLatestPriceCache() =>
      (select(priceCacheEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.fetchDate)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertPriceCache(PriceCacheEntriesCompanion entry) =>
      into(priceCacheEntries).insert(entry);

  // ── Stock Price Cache ──

  Future<List<StockPriceCacheEntry>> getAllStockPriceCache() =>
      select(stockPriceCacheEntries).get();

  Future<void> upsertStockPrice(StockPriceCacheEntriesCompanion entry) =>
      into(stockPriceCacheEntries).insertOnConflictUpdate(entry);

  // ── Daily Snapshots ──

  Future<List<DailySnapshot>> getAllSnapshots() =>
      (select(dailySnapshots)
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<List<DailySnapshot>> getRecentSnapshots(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    return (select(dailySnapshots)
          ..where((t) => t.date.isBiggerOrEqualValue(cutoffStr))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<void> upsertSnapshot(DailySnapshotsCompanion entry) =>
      into(dailySnapshots).insertOnConflictUpdate(entry);

  // ── Settings ──

  Future<String?> getSetting(String key) async {
    final result = await (select(appSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettingsTable).insertOnConflictUpdate(
        AppSettingsTableCompanion(
          key: Value(key),
          value: Value(value),
        ),
      );

  Future<int> deleteSetting(String key) =>
      (delete(appSettingsTable)..where((t) => t.key.equals(key))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}

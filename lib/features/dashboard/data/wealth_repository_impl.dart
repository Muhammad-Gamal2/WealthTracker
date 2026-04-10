import 'dart:math';

import 'package:drift/drift.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/utils/date_formatter.dart';
import 'package:wealth_tracker/features/dashboard/domain/entities/wealth_summary.dart';
import 'package:wealth_tracker/features/dashboard/domain/wealth_repository.dart';

class WealthRepositoryImpl implements WealthRepository {
  final AppDatabase _db;
  final PriceUpdateService _priceService;

  WealthRepositoryImpl(this._db, this._priceService);

  @override
  Future<WealthSummary> getWealthSummary() async {
    // Gather all portfolio items
    final gold = await _db.getAllGoldItems();
    final stocks = await _db.getAllStockItems();
    final liquidity = await _db.getAllLiquidityItems();
    final realEstate = await _db.getAllRealEstateItems();

    // Get stock api symbols to make sure they are in price cache
    final stockApiSymbols = stocks.map((s) {
      return s.market == 'EGX' ? '${s.symbol}:XCAI' : s.symbol;
    }).toList();

    final prices = await _priceService.getLatestPrices(
      stockApiSymbols: stockApiSymbols,
    );

    // Gold value
    double goldEgp = 0;
    for (final item in gold) {
      goldEgp += item.weightGrams * prices.priceForKarat(item.karat);
    }

    // Stocks value — EGX in EGP, US in USD converted to EGP
    double stocksEgp = 0;
    for (final item in stocks) {
      final apiSymbol =
          item.market == 'EGX' ? '${item.symbol}:XCAI' : item.symbol;
      final price = prices.stockPrices[apiSymbol] ?? 0;
      if (item.market == 'EGX') {
        stocksEgp += item.quantity * price;
      } else {
        // US stock priced in USD
        stocksEgp += item.quantity * price * prices.usdToEgpRate;
      }
    }

    // Liquidity value (USD -> EGP)
    double liquidityEgp = 0;
    for (final item in liquidity) {
      liquidityEgp += item.amountUsd * prices.usdToEgpRate;
    }

    // Real estate value (compound appreciation — computed from entity)
    double realEstateEgp = 0;
    for (final item in realEstate) {
      final yearsElapsed =
          DateTime.now().difference(item.purchaseDate).inDays / 365.25;
      realEstateEgp += item.purchaseAmountEgp *
          pow(1 + item.annualAppreciationPercent / 100, yearsElapsed);
    }

    return WealthSummary(
      goldValueEgp: goldEgp,
      stocksValueEgp: stocksEgp,
      liquidityValueEgp: liquidityEgp,
      realEstateValueEgp: realEstateEgp,
      usdToEgpRate: prices.usdToEgpRate,
    );
  }

  @override
  Future<List<SnapshotEntity>> getSnapshots({int? lastNDays}) async {
    final rows = lastNDays != null
        ? await _db.getRecentSnapshots(lastNDays)
        : await _db.getAllSnapshots();
    return rows
        .map((r) => SnapshotEntity(
              date: r.date,
              totalValueEgp: r.totalValueEgp,
              totalValueUsd: r.totalValueUsd,
              goldValueEgp: r.goldValueEgp,
              stocksValueEgp: r.stocksValueEgp,
              liquidityValueEgp: r.liquidityValueEgp,
              realEstateValueEgp: r.realEstateValueEgp,
            ))
        .toList();
  }

  @override
  Future<void> saveSnapshot(WealthSummary summary) async {
    final today = DateFormatter.toKey(DateTime.now());
    await _db.upsertSnapshot(DailySnapshotsCompanion.insert(
      date: today,
      totalValueEgp: summary.totalEgp,
      totalValueUsd: summary.totalUsd,
      goldValueEgp: summary.goldValueEgp,
      stocksValueEgp: summary.stocksValueEgp,
      liquidityValueEgp: summary.liquidityValueEgp,
      realEstateValueEgp: summary.realEstateValueEgp,
    ));
  }
}

import 'dart:developer' as developer;

import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/core/errors/app_exceptions.dart';
import 'package:wealth_tracker/core/services/exchange_rate_service.dart';
import 'package:wealth_tracker/core/services/gold_api_service.dart';
import 'package:wealth_tracker/core/services/stock_api_service.dart';
import 'package:wealth_tracker/core/utils/date_formatter.dart';
import 'package:wealth_tracker/features/settings/domain/settings_repository.dart';
import 'package:drift/drift.dart';

/// Holds the current cached prices in-memory after loading from DB.
class PriceSnapshot {
  final double goldPrice24k;
  final double goldPrice22k;
  final double goldPrice21k;
  final double goldPrice18k;
  final double usdToEgpRate;
  final Map<String, double> stockPrices; // apiSymbol -> price in native currency
  final DateTime fetchDate;
  final bool isStale;

  const PriceSnapshot({
    required this.goldPrice24k,
    required this.goldPrice22k,
    required this.goldPrice21k,
    required this.goldPrice18k,
    required this.usdToEgpRate,
    required this.stockPrices,
    required this.fetchDate,
    this.isStale = false,
  });

  static const empty = PriceSnapshot(
    goldPrice24k: 0,
    goldPrice22k: 0,
    goldPrice21k: 0,
    goldPrice18k: 0,
    usdToEgpRate: 1,
    stockPrices: {},
    fetchDate: _epoch,
    isStale: true,
  );

  static const _epoch = _Epoch();

  double priceForKarat(int karat) {
    switch (karat) {
      case 24:
        return goldPrice24k;
      case 22:
        return goldPrice22k;
      case 21:
        return goldPrice21k;
      case 18:
        return goldPrice18k;
      default:
        return goldPrice24k;
    }
  }
}

// Workaround for const DateTime
class _Epoch implements DateTime {
  const _Epoch();
  @override
  dynamic noSuchMethod(Invocation i) => DateTime.fromMillisecondsSinceEpoch(0);
}

class PriceUpdateService {
  final AppDatabase _db;
  final GoldApiService _goldApi;
  final StockApiService _stockApi;
  final ExchangeRateService _exchangeRateApi;
  final SettingsRepository _settings;

  PriceUpdateService({
    required AppDatabase db,
    required GoldApiService goldApi,
    required StockApiService stockApi,
    required ExchangeRateService exchangeRateApi,
    required SettingsRepository settings,
  })  : _db = db,
        _goldApi = goldApi,
        _stockApi = stockApi,
        _exchangeRateApi = exchangeRateApi,
        _settings = settings;

  /// Returns up-to-date prices. Uses cache if already fetched today.
  /// Pass [forceRefresh] = true to bypass the cache.
  Future<PriceSnapshot> getLatestPrices({
    bool forceRefresh = false,
    List<String> stockApiSymbols = const [],
  }) async {
    final cachedEntry = await _db.getLatestPriceCache();
    final cachedStocks = await _db.getAllStockPriceCache();

    final isToday = cachedEntry != null &&
        DateFormatter.isSameDay(cachedEntry.fetchDate, DateTime.now());

    if (!forceRefresh && isToday && cachedEntry != null) {
      return _buildSnapshot(cachedEntry, cachedStocks);
    }

    // Fetch fresh data — run all three in parallel, tolerate partial failures
    double? goldPrice24k,
        goldPrice22k,
        goldPrice21k,
        goldPrice18k,
        usdToEgpRate;
    Map<String, double> freshStockPrices = {};

    final goldApiKey = await _settings.getGoldApiKey() ?? '';
    final twelveDataKey = await _settings.getTwelveDataApiKey() ?? '';

    developer.log(
      'goldApiKey=${goldApiKey.isEmpty ? "(empty)" : "${goldApiKey.substring(0, 8)}..."}\n'
      'twelveDataKey=${twelveDataKey.isEmpty ? "(empty)" : "${twelveDataKey.substring(0, 8)}..."}',
      name: 'PriceUpdate',
    );

    await Future.wait([
      // Gold
      _goldApi
          .fetchGoldPrices(goldApiKey)
          .then((d) {
            goldPrice24k = d.price24k;
            goldPrice22k = d.price22k;
            goldPrice21k = d.price21k;
            goldPrice18k = d.price18k;
            developer.log('Gold OK: 24k=$goldPrice24k, 22k=$goldPrice22k, 21k=$goldPrice21k, 18k=$goldPrice18k', name: 'PriceUpdate');
          })
          .catchError((e) {
            developer.log('Gold FAILED: $e', name: 'PriceUpdate', level: 1000);
          }),

      // Exchange Rate
      _exchangeRateApi
          .fetchUsdToEgpRate()
          .then((r) {
            usdToEgpRate = r;
            developer.log('USD/EGP rate: $usdToEgpRate', name: 'PriceUpdate');
          })
          .catchError((e) {
            developer.log('Exchange rate FAILED: $e', name: 'PriceUpdate', level: 1000);
          }),

      // Stocks (only if we have symbols and a key)
      if (stockApiSymbols.isNotEmpty && twelveDataKey.isNotEmpty)
        _stockApi
            .fetchStockPrices(stockApiSymbols, twelveDataKey)
            .then((p) {
              freshStockPrices = p;
              developer.log('Stocks OK: ${p.length} prices - $p', name: 'PriceUpdate');
            })
            .catchError((e) {
              developer.log('Stock API FAILED: $e', name: 'PriceUpdate', level: 1000);
            }),
    ]);

    final now = DateTime.now();

    // Upsert price cache row
    await _db.insertPriceCache(PriceCacheEntriesCompanion.insert(
      fetchDate: now,
      goldPrice24k: Value(goldPrice24k ?? cachedEntry?.goldPrice24k ?? 0),
      goldPrice22k: Value(goldPrice22k ?? cachedEntry?.goldPrice22k ?? 0),
      goldPrice21k: Value(goldPrice21k ?? cachedEntry?.goldPrice21k ?? 0),
      goldPrice18k: Value(goldPrice18k ?? cachedEntry?.goldPrice18k ?? 0),
      usdToEgpRate: Value(usdToEgpRate ?? cachedEntry?.usdToEgpRate ?? 1),
    ));

    // Upsert individual stock prices
    for (final entry in freshStockPrices.entries) {
      // Determine currency from symbol (US stocks are USD, EGX are EGP)
      final currency = entry.key.contains(':XCAI') ? 'EGP' : 'USD';
      await _db.upsertStockPrice(StockPriceCacheEntriesCompanion.insert(
        symbol: entry.key,
        price: entry.value,
        currency: Value(currency),
        fetchDate: now,
      ));
    }

    final updatedEntry = await _db.getLatestPriceCache();
    final updatedStocks = await _db.getAllStockPriceCache();
    final snapshot = _buildSnapshot(updatedEntry!, updatedStocks);
    developer.log(
      'Final: gold24k=${snapshot.goldPrice24k}, gold21k=${snapshot.goldPrice21k}, '
      'usdEgp=${snapshot.usdToEgpRate}, stale=${snapshot.isStale}',
      name: 'PriceUpdate',
    );
    return snapshot;
  }

  PriceSnapshot _buildSnapshot(
    PriceCacheEntry entry,
    List<StockPriceCacheEntry> stocks,
  ) {
    final stockMap = {
      for (final s in stocks) s.symbol: s.price,
    };
    return PriceSnapshot(
      goldPrice24k: entry.goldPrice24k,
      goldPrice22k: entry.goldPrice22k,
      goldPrice21k: entry.goldPrice21k,
      goldPrice18k: entry.goldPrice18k,
      usdToEgpRate: entry.usdToEgpRate,
      stockPrices: stockMap,
      fetchDate: entry.fetchDate,
      isStale: !DateFormatter.isSameDay(entry.fetchDate, DateTime.now()),
    );
  }
}

import 'dart:developer' as developer;

import 'package:wealth_tracker/core/database/app_database.dart';
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

enum _PriceCategory { gold, exchangeRate, stocks }

class PriceUpdateService {
  final AppDatabase _db;
  final GoldApiService _goldApi;
  final StockApiService _stockApi;
  final ExchangeRateService _exchangeRateApi;
  final SettingsRepository _settings;

  DateTime? _lastGoldFetch;
  DateTime? _lastExchangeRateFetch;

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

  Future<PriceSnapshot> getGoldPrices({bool forceRefresh = false}) =>
      _fetchPrices(
        categories: {_PriceCategory.gold},
        forceRefresh: forceRefresh,
      );

  Future<PriceSnapshot> getExchangeRate({bool forceRefresh = false}) =>
      _fetchPrices(
        categories: {_PriceCategory.exchangeRate},
        forceRefresh: forceRefresh,
      );

  Future<PriceSnapshot> getStockPrices({
    List<String> stockApiSymbols = const [],
    bool forceRefresh = false,
  }) =>
      _fetchPrices(
        categories: {_PriceCategory.stocks, _PriceCategory.exchangeRate},
        forceRefresh: forceRefresh,
        stockApiSymbols: stockApiSymbols,
      );

  Future<PriceSnapshot> getLatestPrices({
    bool forceRefresh = false,
    List<String> stockApiSymbols = const [],
  }) =>
      _fetchPrices(
        categories: {
          _PriceCategory.gold,
          _PriceCategory.exchangeRate,
          _PriceCategory.stocks,
        },
        forceRefresh: forceRefresh,
        stockApiSymbols: stockApiSymbols,
      );

  Future<PriceSnapshot> _fetchPrices({
    required Set<_PriceCategory> categories,
    bool forceRefresh = false,
    List<String> stockApiSymbols = const [],
  }) async {
    final cachedEntry = await _db.getLatestPriceCache();
    final cachedStocks = await _db.getAllStockPriceCache();
    final now = DateTime.now();

    if (_lastGoldFetch == null && cachedEntry != null &&
        DateFormatter.isSameDay(cachedEntry.fetchDate, now)) {
      _lastGoldFetch = cachedEntry.fetchDate;
    }
    if (_lastExchangeRateFetch == null && cachedEntry != null &&
        DateFormatter.isSameDay(cachedEntry.fetchDate, now)) {
      _lastExchangeRateFetch = cachedEntry.fetchDate;
    }

    final fetchGold = categories.contains(_PriceCategory.gold) &&
        (forceRefresh || _lastGoldFetch == null ||
            !DateFormatter.isSameDay(_lastGoldFetch!, now));

    final fetchExRate = categories.contains(_PriceCategory.exchangeRate) &&
        (forceRefresh || _lastExchangeRateFetch == null ||
            !DateFormatter.isSameDay(_lastExchangeRateFetch!, now));

    final fetchStocks = categories.contains(_PriceCategory.stocks) &&
        stockApiSymbols.isNotEmpty;

    if (!fetchGold && !fetchExRate && !fetchStocks && cachedEntry != null) {
      developer.log(
        'All requested categories cached. Returning from DB.',
        name: 'PriceUpdate',
      );
      return _buildSnapshot(cachedEntry, cachedStocks);
    }

    developer.log(
      'Fetching: gold=$fetchGold, exchangeRate=$fetchExRate, stocks=$fetchStocks',
      name: 'PriceUpdate',
    );

    double? goldPrice24k, goldPrice22k, goldPrice21k, goldPrice18k, usdToEgpRate;
    Map<String, double> freshStockPrices = {};
    final futures = <Future>[];

    if (fetchGold) {
      final goldApiKey = await _settings.getGoldApiKey() ?? '';
      futures.add(
        _goldApi.fetchGoldPrices(goldApiKey).then((d) {
          goldPrice24k = d.price24k;
          goldPrice22k = d.price22k;
          goldPrice21k = d.price21k;
          goldPrice18k = d.price18k;
          _lastGoldFetch = now;
          developer.log('Gold OK: 24k=$goldPrice24k, 21k=$goldPrice21k', name: 'PriceUpdate');
        }).catchError((e) {
          developer.log('Gold FAILED: $e', name: 'PriceUpdate', level: 1000);
        }),
      );
    }

    if (fetchExRate) {
      futures.add(
        _exchangeRateApi.fetchUsdToEgpRate().then((r) {
          usdToEgpRate = r;
          _lastExchangeRateFetch = now;
          developer.log('USD/EGP rate: $usdToEgpRate', name: 'PriceUpdate');
        }).catchError((e) {
          developer.log('Exchange rate FAILED: $e', name: 'PriceUpdate', level: 1000);
        }),
      );
    }

    if (fetchStocks) {
      final twelveDataKey = await _settings.getTwelveDataApiKey() ?? '';
      if (twelveDataKey.isNotEmpty) {
        futures.add(
          _stockApi.fetchStockPrices(stockApiSymbols, twelveDataKey).then((p) {
            freshStockPrices = p;
            developer.log('Stocks OK: ${p.length} prices - $p', name: 'PriceUpdate');
          }).catchError((e) {
            developer.log('Stock API FAILED: $e', name: 'PriceUpdate', level: 1000);
          }),
        );
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    if (fetchGold || fetchExRate) {
      await _db.insertPriceCache(PriceCacheEntriesCompanion.insert(
        fetchDate: now,
        goldPrice24k: Value(goldPrice24k ?? cachedEntry?.goldPrice24k ?? 0),
        goldPrice22k: Value(goldPrice22k ?? cachedEntry?.goldPrice22k ?? 0),
        goldPrice21k: Value(goldPrice21k ?? cachedEntry?.goldPrice21k ?? 0),
        goldPrice18k: Value(goldPrice18k ?? cachedEntry?.goldPrice18k ?? 0),
        usdToEgpRate: Value(usdToEgpRate ?? cachedEntry?.usdToEgpRate ?? 1),
      ));
    }

    for (final entry in freshStockPrices.entries) {
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
    final snapshot = _buildSnapshot(updatedEntry ?? cachedEntry!, updatedStocks);
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

import 'package:signals_flutter/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';
import 'package:wealth_tracker/features/stocks/domain/stock_repository.dart';

final _uuid = const Uuid();

final stockItemsSignal = signal<List<StockEntity>>([]);
final stocksLoadingSignal = signal<bool>(false);
final stocksErrorSignal = signal<String?>(null);
final stocksPricesSignal = signal<PriceSnapshot?>(null);

Future<void> loadStockItems() async {
  stocksLoadingSignal.value = true;
  stocksErrorSignal.value = null;
  try {
    final items = await sl<StockRepository>().getAll();
    stockItemsSignal.value = items;
  } catch (e) {
    stocksErrorSignal.value = e.toString();
  } finally {
    stocksLoadingSignal.value = false;
  }
}

Future<void> loadStockPrices() async {
  try {
    final items = stockItemsSignal.value;
    final p = await sl<PriceUpdateService>().getLatestPrices(
      stockApiSymbols: items.map((s) => s.apiSymbol).toList(),
    );
    stocksPricesSignal.value = p;
  } catch (e) {
    stocksErrorSignal.value = 'Failed to load prices: $e';
  }
}

Future<void> addStockItem({
  required String symbol,
  required String name,
  required double quantity,
  required double purchasePrice,
  required String market,
}) async {
  final currency = market == 'EGX' ? 'EGP' : 'USD';
  final entity = StockEntity(
    id: _uuid.v4(),
    symbol: symbol.toUpperCase(),
    name: name,
    quantity: quantity,
    purchasePrice: purchasePrice,
    market: market,
    currency: currency,
    dateAdded: DateTime.now(),
  );
  await sl<StockRepository>().add(entity);
  await loadStockItems();
}

Future<void> updateStockItem(StockEntity entity) async {
  await sl<StockRepository>().update(entity);
  await loadStockItems();
}

Future<void> deleteStockItem(String id) async {
  await sl<StockRepository>().delete(id);
  await loadStockItems();
}

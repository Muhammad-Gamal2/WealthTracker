import 'package:signals_flutter/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';
import 'package:wealth_tracker/features/liquidity/domain/liquidity_repository.dart';

final _uuid = const Uuid();

final liquidityItemsSignal = signal<List<LiquidityEntity>>([]);
final liquidityLoadingSignal = signal<bool>(false);
final liquidityErrorSignal = signal<String?>(null);
final liquidityPricesSignal = signal<PriceSnapshot?>(null);

Future<void> loadLiquidityItems() async {
  liquidityLoadingSignal.value = true;
  liquidityErrorSignal.value = null;
  try {
    final items = await sl<LiquidityRepository>().getAll();
    liquidityItemsSignal.value = items;
  } catch (e) {
    liquidityErrorSignal.value = e.toString();
  } finally {
    liquidityLoadingSignal.value = false;
  }
}

Future<void> loadLiquidityPrices() async {
  try {
    final p = await sl<PriceUpdateService>()
        .getLatestPrices(stockApiSymbols: const []);
    liquidityPricesSignal.value = p;
  } catch (e) {
    liquidityErrorSignal.value = 'Failed to load rates: $e';
  }
}

Future<void> addLiquidityItem({
  required String label,
  required double amountUsd,
}) async {
  final entity = LiquidityEntity(
    id: _uuid.v4(),
    label: label,
    amountUsd: amountUsd,
    dateAdded: DateTime.now(),
  );
  await sl<LiquidityRepository>().add(entity);
  await loadLiquidityItems();
}

Future<void> updateLiquidityItem(LiquidityEntity entity) async {
  await sl<LiquidityRepository>().update(entity);
  await loadLiquidityItems();
}

Future<void> deleteLiquidityItem(String id) async {
  await sl<LiquidityRepository>().delete(id);
  await loadLiquidityItems();
}

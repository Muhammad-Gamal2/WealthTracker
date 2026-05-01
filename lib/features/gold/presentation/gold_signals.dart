import 'package:signals_flutter/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';
import 'package:wealth_tracker/features/gold/domain/gold_repository.dart';

final _uuid = const Uuid();

final goldItemsSignal = signal<List<GoldEntity>>([]);
final goldLoadingSignal = signal<bool>(false);
final goldErrorSignal = signal<String?>( null);
final goldPricesSignal = signal<PriceSnapshot?>(null);

Future<void> loadGoldItems() async {
  goldLoadingSignal.value = true;
  goldErrorSignal.value = null;
  try {
    final items = await sl<GoldRepository>().getAll();
    goldItemsSignal.value = items;
  } catch (e) {
    goldErrorSignal.value = e.toString();
  } finally {
    goldLoadingSignal.value = false;
  }
}

Future<void> loadGoldPrices({bool forceRefresh = false}) async {
  try {
    final p = await sl<PriceUpdateService>()
        .getLatestPrices(stockApiSymbols: const [], forceRefresh: forceRefresh);
    goldPricesSignal.value = p;
  } catch (e) {
    goldErrorSignal.value = 'Failed to load prices: $e';
  }
}

Future<void> addGoldItem({
  required String label,
  required double weightGrams,
  required int karat,
  double purchasePricePerGram = 0,
}) async {
  final entity = GoldEntity(
    id: _uuid.v4(),
    label: label,
    weightGrams: weightGrams,
    karat: karat,
    purchasePricePerGram: purchasePricePerGram,
    dateAdded: DateTime.now(),
  );
  await sl<GoldRepository>().add(entity);
  await loadGoldItems();
}

Future<void> updateGoldItem(GoldEntity entity) async {
  await sl<GoldRepository>().update(entity);
  await loadGoldItems();
}

Future<void> deleteGoldItem(String id) async {
  await sl<GoldRepository>().delete(id);
  await loadGoldItems();
}

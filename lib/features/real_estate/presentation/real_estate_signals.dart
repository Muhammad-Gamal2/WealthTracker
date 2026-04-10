import 'package:signals_flutter/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';
import 'package:wealth_tracker/features/real_estate/domain/real_estate_repository.dart';

final _uuid = const Uuid();

final realEstateItemsSignal = signal<List<RealEstateEntity>>([]);
final realEstateLoadingSignal = signal<bool>(false);
final realEstateErrorSignal = signal<String?>(null);

Future<void> loadRealEstateItems() async {
  realEstateLoadingSignal.value = true;
  realEstateErrorSignal.value = null;
  try {
    final items = await sl<RealEstateRepository>().getAll();
    realEstateItemsSignal.value = items;
  } catch (e) {
    realEstateErrorSignal.value = e.toString();
  } finally {
    realEstateLoadingSignal.value = false;
  }
}

Future<void> addRealEstateItem({
  required String projectName,
  required DateTime purchaseDate,
  required double purchaseAmountEgp,
  required double annualAppreciationPercent,
}) async {
  final entity = RealEstateEntity(
    id: _uuid.v4(),
    projectName: projectName,
    purchaseDate: purchaseDate,
    purchaseAmountEgp: purchaseAmountEgp,
    annualAppreciationPercent: annualAppreciationPercent,
    dateAdded: DateTime.now(),
  );
  await sl<RealEstateRepository>().add(entity);
  await loadRealEstateItems();
}

Future<void> updateRealEstateItem(RealEstateEntity entity) async {
  await sl<RealEstateRepository>().update(entity);
  await loadRealEstateItems();
}

Future<void> deleteRealEstateItem(String id) async {
  await sl<RealEstateRepository>().delete(id);
  await loadRealEstateItems();
}

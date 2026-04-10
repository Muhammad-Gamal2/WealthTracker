import 'package:drift/drift.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';
import 'package:wealth_tracker/features/real_estate/domain/real_estate_repository.dart';

class RealEstateRepositoryImpl implements RealEstateRepository {
  final AppDatabase _db;
  RealEstateRepositoryImpl(this._db);

  @override
  Future<List<RealEstateEntity>> getAll() async {
    final rows = await _db.getAllRealEstateItems();
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<RealEstateEntity>> watchAll() => _db
      .watchAllRealEstateItems()
      .map((rows) => rows.map(_toEntity).toList());

  @override
  Future<void> add(RealEstateEntity entity) => _db.insertRealEstateItem(
        RealEstateItemsCompanion.insert(
          id: entity.id,
          projectName: entity.projectName,
          purchaseDate: entity.purchaseDate,
          purchaseAmountEgp: entity.purchaseAmountEgp,
          annualAppreciationPercent: entity.annualAppreciationPercent,
          dateAdded: entity.dateAdded,
        ),
      );

  @override
  Future<void> update(RealEstateEntity entity) => _db.updateRealEstateItem(
        RealEstateItemsCompanion(
          id: Value(entity.id),
          projectName: Value(entity.projectName),
          purchaseDate: Value(entity.purchaseDate),
          purchaseAmountEgp: Value(entity.purchaseAmountEgp),
          annualAppreciationPercent: Value(entity.annualAppreciationPercent),
          dateAdded: Value(entity.dateAdded),
        ),
      );

  @override
  Future<void> delete(String id) => _db.deleteRealEstateItem(id);

  RealEstateEntity _toEntity(RealEstateItem row) => RealEstateEntity(
        id: row.id,
        projectName: row.projectName,
        purchaseDate: row.purchaseDate,
        purchaseAmountEgp: row.purchaseAmountEgp,
        annualAppreciationPercent: row.annualAppreciationPercent,
        dateAdded: row.dateAdded,
      );
}

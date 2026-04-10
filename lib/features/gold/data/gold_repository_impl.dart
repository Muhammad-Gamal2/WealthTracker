import 'package:drift/drift.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';
import 'package:wealth_tracker/features/gold/domain/gold_repository.dart';

class GoldRepositoryImpl implements GoldRepository {
  final AppDatabase _db;
  GoldRepositoryImpl(this._db);

  @override
  Future<List<GoldEntity>> getAll() async {
    final rows = await _db.getAllGoldItems();
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<GoldEntity>> watchAll() =>
      _db.watchAllGoldItems().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<void> add(GoldEntity entity) => _db.insertGoldItem(
        GoldItemsCompanion.insert(
          id: entity.id,
          label: Value(entity.label),
          weightGrams: entity.weightGrams,
          karat: Value(entity.karat),
          dateAdded: entity.dateAdded,
        ),
      );

  @override
  Future<void> update(GoldEntity entity) => _db.updateGoldItem(
        GoldItemsCompanion(
          id: Value(entity.id),
          label: Value(entity.label),
          weightGrams: Value(entity.weightGrams),
          karat: Value(entity.karat),
          dateAdded: Value(entity.dateAdded),
        ),
      );

  @override
  Future<void> delete(String id) => _db.deleteGoldItem(id);

  GoldEntity _toEntity(GoldItem row) => GoldEntity(
        id: row.id,
        label: row.label,
        weightGrams: row.weightGrams,
        karat: row.karat,
        dateAdded: row.dateAdded,
      );
}

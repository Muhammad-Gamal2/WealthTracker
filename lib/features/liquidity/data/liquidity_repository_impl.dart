import 'package:drift/drift.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';
import 'package:wealth_tracker/features/liquidity/domain/liquidity_repository.dart';

class LiquidityRepositoryImpl implements LiquidityRepository {
  final AppDatabase _db;
  LiquidityRepositoryImpl(this._db);

  @override
  Future<List<LiquidityEntity>> getAll() async {
    final rows = await _db.getAllLiquidityItems();
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<LiquidityEntity>> watchAll() =>
      _db.watchAllLiquidityItems().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<void> add(LiquidityEntity entity) => _db.insertLiquidityItem(
        LiquidityItemsCompanion.insert(
          id: entity.id,
          label: Value(entity.label),
          amountUsd: entity.amountUsd,
          dateAdded: entity.dateAdded,
        ),
      );

  @override
  Future<void> update(LiquidityEntity entity) => _db.updateLiquidityItem(
        LiquidityItemsCompanion(
          id: Value(entity.id),
          label: Value(entity.label),
          amountUsd: Value(entity.amountUsd),
          dateAdded: Value(entity.dateAdded),
        ),
      );

  @override
  Future<void> delete(String id) => _db.deleteLiquidityItem(id);

  LiquidityEntity _toEntity(LiquidityItem row) => LiquidityEntity(
        id: row.id,
        label: row.label,
        amountUsd: row.amountUsd,
        dateAdded: row.dateAdded,
      );
}

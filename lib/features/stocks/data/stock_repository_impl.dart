import 'package:drift/drift.dart';
import 'package:wealth_tracker/core/database/app_database.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';
import 'package:wealth_tracker/features/stocks/domain/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  final AppDatabase _db;
  StockRepositoryImpl(this._db);

  @override
  Future<List<StockEntity>> getAll() async {
    final rows = await _db.getAllStockItems();
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<StockEntity>> watchAll() =>
      _db.watchAllStockItems().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<void> add(StockEntity entity) => _db.insertStockItem(
        StockItemsCompanion.insert(
          id: entity.id,
          symbol: entity.symbol,
          name: Value(entity.name),
          quantity: entity.quantity,
          purchasePrice: entity.purchasePrice,
          market: Value(entity.market),
          currency: Value(entity.currency),
          dateAdded: entity.dateAdded,
        ),
      );

  @override
  Future<void> update(StockEntity entity) => _db.updateStockItem(
        StockItemsCompanion(
          id: Value(entity.id),
          symbol: Value(entity.symbol),
          name: Value(entity.name),
          quantity: Value(entity.quantity),
          purchasePrice: Value(entity.purchasePrice),
          market: Value(entity.market),
          currency: Value(entity.currency),
          dateAdded: Value(entity.dateAdded),
        ),
      );

  @override
  Future<void> delete(String id) => _db.deleteStockItem(id);

  StockEntity _toEntity(StockItem row) => StockEntity(
        id: row.id,
        symbol: row.symbol,
        name: row.name,
        quantity: row.quantity,
        purchasePrice: row.purchasePrice,
        market: row.market,
        currency: row.currency,
        dateAdded: row.dateAdded,
      );
}

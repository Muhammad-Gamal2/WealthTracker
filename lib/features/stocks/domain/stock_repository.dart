import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';

abstract class StockRepository {
  Future<List<StockEntity>> getAll();
  Stream<List<StockEntity>> watchAll();
  Future<void> add(StockEntity entity);
  Future<void> update(StockEntity entity);
  Future<void> delete(String id);
}

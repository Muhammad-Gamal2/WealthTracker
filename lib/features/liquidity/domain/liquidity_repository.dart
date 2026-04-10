import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';

abstract class LiquidityRepository {
  Future<List<LiquidityEntity>> getAll();
  Stream<List<LiquidityEntity>> watchAll();
  Future<void> add(LiquidityEntity entity);
  Future<void> update(LiquidityEntity entity);
  Future<void> delete(String id);
}

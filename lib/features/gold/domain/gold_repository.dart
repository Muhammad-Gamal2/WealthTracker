import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';

abstract class GoldRepository {
  Future<List<GoldEntity>> getAll();
  Stream<List<GoldEntity>> watchAll();
  Future<void> add(GoldEntity entity);
  Future<void> update(GoldEntity entity);
  Future<void> delete(String id);
}

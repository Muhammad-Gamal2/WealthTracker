import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';

abstract class RealEstateRepository {
  Future<List<RealEstateEntity>> getAll();
  Stream<List<RealEstateEntity>> watchAll();
  Future<void> add(RealEstateEntity entity);
  Future<void> update(RealEstateEntity entity);
  Future<void> delete(String id);
}



import '../../../domain/entities/home/home_entity.dart';
import '../../models/home/home_model.dart';

/// Mappers for HOME
extension HomeModelMapper on HomeModel {
  /// Converts data model to domain entity
  HomeEntity toDomain() {
    return HomeEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
  }
}

extension HomeEntityMapper on HomeEntity {
  /// Converts domain entity to data model
  HomeModel toData() {
    return HomeModel(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
  }
}
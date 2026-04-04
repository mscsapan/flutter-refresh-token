import '../../../domain/entities/setting/setting_entity.dart';
import '../../models/setting/setting_model.dart';

/// Mappers for SETTING
extension SettingModelMapper on SettingModel {
  /// Converts data model to domain entity
  SettingEntity toDomain() {
    return SettingEntity(
      success: success,
      message: message,
      version: version,
      developer: developer,
      designation: designation,
      email: email,
      phone: phone,
    );
  }
}

extension SettingEntityMapper on SettingEntity {
  /// Converts domain entity to data model
  SettingModel toData() {
    return SettingModel(
      success: success,
      message: message,
      version: version,
      developer: developer,
      designation: designation,
      email: email,
      phone: phone,
    );
  }
}

import '../../../domain/entities/auth/user_entity.dart';
import '../../models/auth/user_model.dart';

/// Mappers for USERRESPONSE
extension UserMapper on UserModel {
  /// Converts data model to domain entity
  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      image: image,
      status: status,
    );
  }
}

extension UserEntityMapper on UserEntity {
  /// Converts domain entity to data model
  UserModel toData() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      image: image,
      status: status,
    );
  }
}
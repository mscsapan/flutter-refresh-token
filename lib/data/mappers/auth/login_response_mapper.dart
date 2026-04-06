import '../../../domain/entities/auth/login_response_entity.dart';
import '../../models/auth/login_response_model.dart';
import 'user_mapper.dart';

/// Mappers for USERRESPONSE
extension LoginResponseMapper on LoginResponseModel {
  /// Converts data model to domain entity
  LoginResponseEntity toDomain() {
    return LoginResponseEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      isVendor: isVendor,
      expireIn: expireIn,
      user: user?.toDomain(),
    );
  }
}

extension LoginResponseEntityMapper on LoginResponseEntity {
  /// Converts domain entity to data model
  LoginResponseModel toData() {
    return LoginResponseModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      isVendor: isVendor,
      expireIn: expireIn,
      user: user?.toData(),
    );
  }
}
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../models/auth/user_response_model.dart';

extension UserResponseModelMapper on UserResponse {
  User toDomain() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      image: image,
      status: status,
    );
  }
}

extension UserResponseModelAuthMapper on UserResponseModel {
  AuthResponse toDomain() {
    return AuthResponse(
      accessToken: accessToken,
      tokenType: tokenType,
      isVendor: isVendor,
      expireIn: expireIn,
      user: user?.toDomain(),
    );
  }
}

extension UserDomainMapper on User {
  UserResponse toData() {
    return UserResponse(
      id: id,
      name: name,
      email: email,
      phone: phone,
      image: image,
      status: status,
    );
  }
}

extension AuthResponseDomainMapper on AuthResponse {
  UserResponseModel toData() {
    return UserResponseModel(
      accessToken: accessToken,
      tokenType: tokenType,
      isVendor: isVendor,
      expireIn: expireIn,
      user: user?.toData(),
    );
  }
}

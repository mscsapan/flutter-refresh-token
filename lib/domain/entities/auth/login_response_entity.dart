import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// Domain Entity for USERRESPONSE
/// 
/// This represents the core business object in the domain layer.
class LoginResponseEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int isVendor;
  final int expireIn;
  final UserEntity? user;

  const LoginResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.isVendor,
    required this.expireIn,
    required this.user,
  });

  LoginResponseEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? isVendor,
    int? expireIn,
    UserEntity? user,
  }) {
    return LoginResponseEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      isVendor: isVendor ?? this.isVendor,
      expireIn: expireIn ?? this.expireIn,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, isVendor, expireIn, user];

  @override
  String toString() {
    return 'UserResponseModelEntity{accessToken: \$accessToken, refreshToken: \$refreshToken, tokenType: \$tokenType, isVendor: \$isVendor, expireIn: \$expireIn, user: \$user}';
  }
}
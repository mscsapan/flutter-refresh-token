import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int isVendor;
  final int expireIn;
  final User? user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken = '',
    required this.tokenType,
    required this.isVendor,
    required this.expireIn,
    required this.user,
  });

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? isVendor,
    int? expireIn,
    User? user,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      isVendor: isVendor ?? this.isVendor,
      expireIn: expireIn ?? this.expireIn,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props =>
      [accessToken, refreshToken, tokenType, isVendor, expireIn, user];
}

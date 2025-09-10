import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String tokenType;
  final int isVendor;
  final int expireIn;
  final User? user;

  const AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.isVendor,
    required this.expireIn,
    required this.user,
  });

  AuthResponse copyWith({
    String? accessToken,
    String? tokenType,
    int? isVendor,
    int? expireIn,
    User? user,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      isVendor: isVendor ?? this.isVendor,
      expireIn: expireIn ?? this.expireIn,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [accessToken, tokenType, isVendor, expireIn, user];
}

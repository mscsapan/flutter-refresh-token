import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'user_model.dart';

class LoginResponseModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int isVendor;
  final int expireIn;
  final UserModel? user;

  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken = '',
    required this.tokenType,
    required this.isVendor,
    required this.expireIn,
    required this.user,
  });

  LoginResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? isVendor,
    int? expireIn,
    UserModel? user,
  }) {
    return LoginResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      isVendor: isVendor ?? this.isVendor,
      expireIn: expireIn ?? this.expireIn,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'token_type': tokenType,
      'is_vendor': isVendor,
      'expires_in': expireIn,
      'user': user?.toMap(),
    };
  }

  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    return LoginResponseModel(
      accessToken: map['accessToken'] ?? '',
      refreshToken: map['refreshToken'] ?? '',
      tokenType: map['token_type'] ?? '',
      isVendor: map['is_vendor'] ?? 0,
      expireIn: map['expires_in'] ?? 0,
      user: map['user'] != null
          ? UserModel.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginResponseModel.fromJson(String source) => LoginResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      accessToken,
      refreshToken,
      tokenType,
      isVendor,
      expireIn,
      user,
    ];
  }
}

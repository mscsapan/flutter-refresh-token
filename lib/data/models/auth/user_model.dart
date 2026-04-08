import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../presentation/bloc/auth/login_bloc.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final int status;
  final bool isShow;
  final UserModel ? userInfo;
  final LoginState loginState;

  const UserModel({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.image = '',
    this.status = 0,
    this.userInfo,
    this.isShow = true,
    this.loginState = const LoginInitial(),
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    int? status,
    bool ? isShow,
    UserModel? userInfo,
    LoginState ? loginState,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      status: status ?? this.status,
      isShow: isShow ?? this.isShow,
      userInfo: userInfo?? this.userInfo,
      loginState: loginState ?? this.loginState,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': phone,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      image: map['image'] ?? '',
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      email,
      phone,
      image,
      status,
      isShow,
      userInfo,
      loginState,
    ];
  }
}
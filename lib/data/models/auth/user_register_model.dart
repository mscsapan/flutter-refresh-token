import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserRegisterModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final int status;

  const UserRegisterModel({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.image = '',
    this.status = 0,
  });

  UserRegisterModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    int? status,
  }) {
    return UserRegisterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'status': status,
    };
  }

  factory UserRegisterModel.fromMap(Map<String, dynamic> map) {
    return UserRegisterModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      image: map['image'] ?? '',
      status: map['status'] != null ? int.parse(map['status'].toString()) : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRegisterModel.fromJson(String source) =>
      UserRegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      name,
      email,
      phone,
      image,
      status,
    ];
  }
}
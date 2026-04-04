// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class SettingModel extends Equatable {
  final bool success;
  final String message;
  final String version;
  final String developer;
  final String designation;
  final String email;
  final String phone;
  const SettingModel({
    required this.success,
    required this.message,
    required this.version,
    required this.developer,
    required this.designation,
    required this.email,
    required this.phone,
  });

  SettingModel copyWith({
    bool? success,
    String? message,
    String? version,
    String? developer,
    String? designation,
    String? email,
    String? phone,
  }) {
    return SettingModel(
      success: success ?? this.success,
      message: message ?? this.message,
      version: version ?? this.version,
      developer: developer ?? this.developer,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'version': version,
      'developer': developer,
      'designation': designation,
      'email': email,
      'phone': phone,
    };
  }

  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      version: map['version'] ?? '',
      developer: map['developer'] ?? '',
      designation: map['designation'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingModel.fromJson(String source) => SettingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      success,
      message,
      version,
      developer,
      designation,
      email,
      phone,
    ];
  }
}

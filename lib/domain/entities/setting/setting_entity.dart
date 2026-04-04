import 'package:equatable/equatable.dart';

/// Domain Entity for SETTING
/// 
/// This represents the core business object in the domain layer.
class SettingEntity extends Equatable {
  final bool success;
  final String message;
  final String version;
  final String developer;
  final String designation;
  final String email;
  final String phone;

  const SettingEntity({
    required this.success,
    required this.message,
    required this.version,
    required this.developer,
    required this.designation,
    required this.email,
    required this.phone,
  });

  SettingEntity copyWith({
    bool? success,
    String? message,
    String? version,
    String? developer,
    String? designation,
    String? email,
    String? phone,
  }) {
    return SettingEntity(
      success: success ?? this.success,
      message: message ?? this.message,
      version: version ?? this.version,
      developer: developer ?? this.developer,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [success, message, version, developer, designation, email, phone];

  @override
  String toString() {
    return 'SettingEntity{success: \$success, message: \$message, version: \$version, developer: \$developer, designation: \$designation, email: \$email, phone: \$phone}';
  }
}
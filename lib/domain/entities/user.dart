import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final int status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.status,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    int? status,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [id, name, email, phone, image, status];
}

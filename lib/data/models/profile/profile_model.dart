import 'dart:convert';
import 'package:equatable/equatable.dart';

// Generated code - do not modify by hand
// To preserve custom changes, add // MANUAL comment above modified methods

class ProfileModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final double price;
  final ProfileModel? userInfo;
  final List<String?>? images;
  final List<ProfileModel?>? followers;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.price,
    required this.userInfo,
    required this.images,
    required this.followers,
  });

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    double? price,
    ProfileModel? userInfo,
    List<String?>? images,
    List<ProfileModel?>? followers,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      price: price ?? this.price,
      userInfo: userInfo ?? this.userInfo,
      images: images ?? this.images,
      followers: followers ?? this.followers,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'price': price,
      'userInfo': userInfo?.toMap(),
      'images': images?.map((x) => x).toList(),
      'followers': followers?.map((x) => x?.toMap()).toList(),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      price: map['price'] != null ? double.parse(map['price'].toString()) : 0.0,
      userInfo: map['userInfo'] != null ? ProfileModel.fromMap(map['userInfo'] as Map<String, dynamic>) : null,
      images: map['images'] != null ? List<String>.from((map['images'] as List<dynamic>).map<String>((x) => x),) : null,
      followers: map['followers'] != null ? (map['followers'] as List<dynamic>).map((x) => ProfileModel.fromMap(x as Map<String, dynamic>)).toList() : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [id, name, email, price, userInfo, images, followers];
  }
}

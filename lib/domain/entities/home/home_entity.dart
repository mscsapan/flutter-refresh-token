import 'package:equatable/equatable.dart';

/// Domain Entity for HOME
/// 
/// This represents the core business object in the domain layer.
class HomeEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  const HomeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  HomeEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return HomeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted];

  @override
  String toString() {
    return 'HomeEntity{id: \$id, title: \$title, description: \$description, isCompleted: \$isCompleted}';
  }
}
import 'package:equatable/equatable.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {
  const SettingInitial();
}

class SettingLoading extends SettingState {
  const SettingLoading();
}

class SettingLoaded extends SettingState {
  final dynamic settings;

  const SettingLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingError extends SettingState {
  final String message;
  final int statusCode;

  const SettingError({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

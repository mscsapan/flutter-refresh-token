part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginLoaded extends LoginState {
  final AuthResponse authResponse;

  const LoginLoaded({required this.authResponse});

  @override
  List<Object> get props => [authResponse];
}

class LoginError extends LoginState {
  final String message;
  final int statusCode;

  const LoginError({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

class LoginFormValidationError extends LoginState {
  final Errors errors;

  const LoginFormValidationError(this.errors);

  @override
  List<Object> get props => [errors];
}

// Logout states
class LogoutLoading extends LoginState {
  const LogoutLoading();
}

class LogoutLoaded extends LoginState {
  final String message;

  const LogoutLoaded({required this.message});

  @override
  List<Object> get props => [message];
}

class LogoutError extends LoginState {
  final String message;
  final int statusCode;

  const LogoutError({
    required this.message,
    required this.statusCode,
  });

  @override
  List<Object> get props => [message, statusCode];
}

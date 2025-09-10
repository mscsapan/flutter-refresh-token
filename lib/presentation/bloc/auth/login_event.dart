part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginEventSubmit extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginEventSubmit({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
}

class LoginEventLogout extends LoginEvent {
  const LoginEventLogout();
}

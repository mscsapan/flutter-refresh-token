part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}


class LoginInfoAddEvent extends LoginEvent {
  final UserModel Function(UserModel existing) addUserInfo;

  const LoginInfoAddEvent(this.addUserInfo);

  @override
  List<Object?> get props => [addUserInfo];
}

class LoginEventSubmit extends LoginEvent {}

class LoginEventLogout extends LoginEvent {
  const LoginEventLogout();
}

/// Dispatched when the [AuthInterceptor] detects that the session has expired
/// (refresh token is also invalid / missing).
class LoginEventSessionExpired extends LoginEvent {
  final String? message;

  const LoginEventSessionExpired({this.message});

  @override
  List<Object?> get props => [message];
}

class LoginEventTokensUpdated extends LoginEvent {
  final String accessToken;
  final String? refreshToken;

  const LoginEventTokensUpdated({required this.accessToken, this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

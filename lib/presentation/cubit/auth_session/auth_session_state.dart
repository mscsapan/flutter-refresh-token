import 'package:equatable/equatable.dart';

/// States for [AuthSessionCubit].
///
/// These represent the **session lifecycle**, not login/logout UI flows
/// (which remain in [LoginBloc]).
abstract class AuthSessionState extends Equatable {
  const AuthSessionState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no session activity yet.
class AuthSessionInitial extends AuthSessionState {
  const AuthSessionInitial();
}

/// The session cubit is currently refreshing the access token.
class AuthSessionRefreshing extends AuthSessionState {
  const AuthSessionRefreshing();
}

/// Token was refreshed successfully — the user remains authenticated.
class AuthSessionAuthenticated extends AuthSessionState {
  const AuthSessionAuthenticated();
}

/// The session has expired and cannot be recovered.
///
/// The UI should listen for this state and navigate the user to the login
/// screen, optionally displaying [message].
class AuthSessionExpired extends AuthSessionState {
  final String message;

  const AuthSessionExpired({required this.message});

  @override
  List<Object> get props => [message];
}

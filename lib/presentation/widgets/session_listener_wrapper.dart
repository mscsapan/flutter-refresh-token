import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/navigation_service.dart';
import '../../data/models/auth/user_model.dart';
import '../bloc/auth/login_bloc.dart';
import '../cubit/auth_session/auth_session_cubit.dart';
import '../cubit/auth_session/auth_session_state.dart';
import '../routes/route_names.dart';

/// Wraps the app's child widget with global [BlocListener]s that react to
/// session-state changes from **two** sources:
///
/// | Source             | State            | Trigger                              |
/// |--------------------|------------------|--------------------------------------|
/// | [AuthSessionCubit] | [AuthSessionExpired] | 401 intercepted by [AuthInterceptor] / [TokenRefreshService] |
/// | [LoginBloc]        | [SessionExpired] | Legacy / explicit event dispatch     |
///
/// On either expiry state this widget:
///  1. Shows a SnackBar informing the user.
///  2. Navigates to the auth screen and clears the navigation stack.
///
/// Usage in `main.dart` (unchanged):
/// ```dart
/// SessionListenerWrapper(child: MaterialApp(…))
/// ```
class SessionListenerWrapper extends StatelessWidget {
  final Widget child;

  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ── Primary: AuthSessionCubit ─────────────────────────────────────
        // Triggered by TokenRefreshService when the interceptor receives a 401
        // that cannot be recovered (refresh failed or no refresh token).
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) => current is AuthSessionExpired,
          listener: (context, state) {
            if (state is AuthSessionExpired) {
              _handleSessionExpired(context, state.message);
            }
          },
        ),

        // ── Legacy: LoginBloc ─────────────────────────────────────────────
        // Kept for backward compatibility — e.g. if LoginEventSessionExpired
        // is dispatched explicitly from somewhere in the UI layer.
        BlocListener<LoginBloc, UserModel>(
          listenWhen: (previous, current) => current.loginState is SessionExpired,
          listener: (context, login) {
            final state = login.loginState;
            if (state is SessionExpired) {
              _handleSessionExpired(context, state.message);
            }
          },
        ),
      ],
      child: child,
    );
  }

  void _handleSessionExpired(BuildContext context, String message) {
    NavigationService.errorSnackBar(context, message);

    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.authScreen,
      (route) => false,
    );
  }
}

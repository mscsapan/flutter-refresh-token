import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/login_bloc.dart';
import '../routes/route_names.dart';

/// Wraps the app's child widget with a global [BlocListener] that reacts to
/// [SessionExpired] state from the [LoginBloc].
///
/// When the token refresh fails and [SessionExpired] is emitted, this widget:
///  1. Shows a SnackBar informing the user.
///  2. Navigates to the auth screen and clears the navigation stack.
///
/// Usage in `main.dart`:
/// ```dart
/// SessionListenerWrapper(child: MaterialApp(…))
/// ```
class SessionListenerWrapper extends StatelessWidget {
  final Widget child;

  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => current is SessionExpired,
      listener: (context, state) {
        if (state is SessionExpired) {
          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate to auth screen and remove all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.authScreen,
            (route) => false,
          );
        }
      },
      child: child,
    );
  }
}

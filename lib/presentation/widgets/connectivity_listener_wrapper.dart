import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/navigation_service.dart';
import '../bloc/internet_status/internet_status_bloc.dart';

/// App-level listener for connectivity transitions.
///
/// This keeps global online/offline UX concerns out of individual pages.
class ConnectivityListenerWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetStatusBloc, InternetStatusState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType &&
          (current is InternetStatusLostState || current is InternetStatusBackState),
      listener: (context, state) {
        if (state is InternetStatusLostState) {
          NavigationService.errorSnackBar(context, 'Your internet connection was lost');
        } else if (state is InternetStatusBackState) {
          NavigationService.showSnackBar(context, 'Your internet connection was restored');
        }
      },
      child: child,
    );
  }
}

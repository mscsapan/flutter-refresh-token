import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/internet_status/internet_status_bloc.dart';

/// A mixin for [State] classes that need to **automatically reload data**
/// when the internet connection is restored.
///
/// ## Usage
///
/// 1. Mix it into your `State`:
/// ```dart
/// class _MyPageState extends State<MyPage> with ConnectivityAwareMixin {
///   @override
///   void onConnectionRestored() {
///     // Re-fetch your data here
///     context.read<MyBloc>().add(FetchDataEvent());
///   }
///
///   @override
///   Widget build(BuildContext context) => ...;
/// }
/// ```
///
/// 2. The mixin automatically:
///   - Listens to the [InternetStatusBloc]
///   - Tracks if the connection was previously lost
///   - Calls [onConnectionRestored] only on transitions from lost → restored
///   - Does NOT call it on initial app load (only on genuine reconnections)
///
/// This is separate from the [RetryInterceptor] which handles in-flight
/// requests. This mixin handles re-triggering page-level data loading
/// when the user has already seen an error state.
mixin ConnectivityAwareMixin<T extends StatefulWidget> on State<T> {
  /// Whether the connection has been lost at least once since this page
  /// was created. Prevents firing [onConnectionRestored] on first load.
  bool _wasDisconnected = false;

  /// Override this method to define what should happen when the internet
  /// connection is restored (e.g., re-fetch page data).
  void onConnectionRestored();

  /// Optional: Override to react to connection loss (e.g., show a banner).
  void onConnectionLost() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We set up the listener only once via didChangeDependencies
  }

  /// Builds a [BlocListener] that wraps your page content.
  ///
  /// Use this in your build method:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return buildWithConnectivity(
  ///     child: Scaffold(…),
  ///   );
  /// }
  /// ```
  Widget buildWithConnectivity({required Widget child}) {
    return BlocListener<InternetStatusBloc, InternetStatusState>(
      listener: (context, state) {
        if (state is InternetStatusLostState) {
          _wasDisconnected = true;
          onConnectionLost();
        } else if (state is InternetStatusBackState && _wasDisconnected) {
          _wasDisconnected = false;
          onConnectionRestored();
        }
      },
      child: child,
    );
  }
}

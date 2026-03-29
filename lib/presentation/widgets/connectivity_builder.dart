import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/internet_status/internet_status_bloc.dart';

/// A widget that **automatically re-fetches data** when internet connectivity
/// is restored — without any mixins, overrides, or boilerplate.
///
/// ## Why this instead of a mixin?
/// - ✅ Works with both `StatelessWidget` and `StatefulWidget`
/// - ✅ Wrap only the body — not the entire Scaffold/AppBar
/// - ✅ One line to add — just wrap your body content
/// - ✅ Optional "No internet" banner shown automatically
/// - ✅ Auto-calls [onRetry] only on genuine lost → restored transitions
///
/// ## Usage
///
/// ```dart
/// // StatelessWidget — works!
/// class ProfilePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Profile')),
///       body: ConnectivityBuilder(
///         onRetry: () => context.read<ProfileBloc>().add(FetchProfile()),
///         child: BlocBuilder<ProfileBloc, ProfileState>(
///           builder: (context, state) => YourContent(...),
///         ),
///       ),
///     );
///   }
/// }
///
/// // StatefulWidget — also works!
/// class _HomeState extends State<HomePage> {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Home')),
///       body: ConnectivityBuilder(
///         onRetry: () => _fetchData(),
///         child: _buildContent(),
///       ),
///     );
///   }
/// }
/// ```
class ConnectivityBuilder extends StatefulWidget {
  /// The main content to display.
  final Widget child;

  /// Called automatically when internet connection transitions from
  /// lost → restored. Put your API re-fetch logic here.
  ///
  /// This is NOT called on the initial load — only on genuine reconnections.
  final VoidCallback? onRetry;

  /// Whether to show a "No internet" banner when connection is lost.
  /// Defaults to `true`.
  final bool showBanner;

  /// Custom widget to show when there's no internet.
  /// If null, a default Material banner is shown.
  final Widget? offlineBanner;

  const ConnectivityBuilder({
    super.key,
    required this.child,
    this.onRetry,
    this.showBanner = true,
    this.offlineBanner,
  });

  @override
  State<ConnectivityBuilder> createState() => _ConnectivityBuilderState();
}

class _ConnectivityBuilderState extends State<ConnectivityBuilder>
    with SingleTickerProviderStateMixin {
  /// Tracks if the connection was lost at least once. Prevents calling
  /// [onRetry] on the initial app load.
  bool _wasDisconnected = false;

  /// Controls the slide animation for the offline banner.
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetStatusBloc, InternetStatusState>(
      listener: (context, state) {
        if (state is InternetStatusLostState) {
          _wasDisconnected = true;
          if (widget.showBanner) {
            _animationController.forward();
          }
        } else if (state is InternetStatusBackState) {
          if (widget.showBanner) {
            _animationController.reverse();
          }
          if (_wasDisconnected) {
            _wasDisconnected = false;
            widget.onRetry?.call();
          }
        }
      },
      child: widget.showBanner
          ? Column(
              children: [
                // Offline banner — slides in/out from the top
                SlideTransition(
                  position: _slideAnimation,
                  child: widget.offlineBanner ?? const _DefaultOfflineBanner(),
                ),
                // Main content fills the remaining space
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default offline banner
// ─────────────────────────────────────────────────────────────────────────────

class _DefaultOfflineBanner extends StatelessWidget {
  const _DefaultOfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No internet connection. Retrying when connected…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

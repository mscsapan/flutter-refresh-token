import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/token_manager.dart';
import '../../../core/network/token_refresh_service.dart';
import 'auth_session_state.dart';

/// Manages the authentication **session** lifecycle.
///
/// This cubit is **separate** from [LoginBloc] because they address different
/// concerns:
///
/// | Concern                | Managed by          |
/// |------------------------|---------------------|
/// | Login / logout UI flow | [LoginBloc]         |
/// | Token refresh & expiry | [AuthSessionCubit]  |
///
/// ## How it works
///
/// 1. [TokenRefreshService] is the network-layer service that performs the
///    actual token refresh (using [UserResponseModel] for parsing).
/// 2. [AuthInterceptor] calls [TokenRefreshService.attemptRefresh] on 401.
/// 3. [TokenRefreshService] broadcasts [SessionEvent]s on its stream.
/// 4. This cubit **listens** to the stream and emits the corresponding
///    [AuthSessionState] so the UI can react (e.g. navigate to login on
///    [AuthSessionExpired]).
///
/// The cubit can also be used to explicitly trigger a refresh from the UI via
/// [refreshSession].
class AuthSessionCubit extends Cubit<AuthSessionState> {
  final TokenRefreshService _tokenRefreshService;
  late final StreamSubscription<SessionEvent> _subscription;

  AuthSessionCubit({
    required TokenRefreshService tokenRefreshService,
  })  : _tokenRefreshService = tokenRefreshService,
        super(const AuthSessionInitial()) {
    _subscription = _tokenRefreshService.sessionStream.listen(_onSessionEvent);
  }

  // ── React to service events ──────────────────────────────────────────────

  void _onSessionEvent(SessionEvent event) {
    switch (event) {
      case SessionEvent.refreshed:
        emit(const AuthSessionAuthenticated());
        break;
      case SessionEvent.expired:
        _performLocalCleanup();
        emit(const AuthSessionExpired(
          message: 'Session expired. Please login again.',
        ));
        break;
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Explicitly triggers a token refresh.
  ///
  /// Returns `true` if the refresh succeeded, `false` otherwise.
  /// Emits [AuthSessionRefreshing] → [AuthSessionAuthenticated] on success,
  /// or [AuthSessionRefreshing] → [AuthSessionExpired] on failure.
  Future<bool> refreshSession() async {
    emit(const AuthSessionRefreshing());

    final success = await _tokenRefreshService.attemptRefresh();

    if (!success) {
      _performLocalCleanup();
      emit(const AuthSessionExpired(
        message: 'Session expired. Please login again.',
      ));
    }

    return success;
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  /// Clears tokens and resets the Dio singleton so a fresh instance with clean
  /// state is created on the next login.
  void _performLocalCleanup() {
    TokenManager.instance.clearTokens();
    DioClient.reset();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

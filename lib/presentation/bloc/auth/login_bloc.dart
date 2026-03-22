import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_manager.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/auth_response.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';
import '../../../data/models/errors/errors_model.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthUseCases _authUseCases;

  AuthResponse? _user;

  bool get isLoggedIn => _user != null && _user!.accessToken.isNotEmpty;

  AuthResponse? get userInformation => _user;

  set saveUserData(AuthResponse userData) => _user = userData;

  LoginBloc({required AuthUseCases authUseCases})
    : _authUseCases = authUseCases,
      super(const LoginInitial()) {
    on<LoginEventSubmit>(_onLoginSubmit);
    on<LoginEventLogout>(_onLogout);
    on<LoginEventSessionExpired>(_onSessionExpired);

    // Load existing user info on initialization
    _loadExistingUser();
  }

  void _loadExistingUser() {
    final result = _authUseCases.getExistingUserInfo(NoParams());
    result.fold((failure) => _user = null, (success) {
      saveUserData = success;
      log('Existing user loaded: $success', name: 'saved-user-data');
    });
  }

  Future<void> saveUserCredentials(String email, String password) async {
    final params = CredentialsParams(email: email, password: password);
    await _authUseCases.saveCredentials(params);
  }

  Future<void> removeCredentials() async {
    await _authUseCases.removeCredentials(NoParams());
  }

  Future<void> _onLoginSubmit(LoginEventSubmit event,
      Emitter<LoginState> emit) async {
    emit(const LoginLoading());

    final params = LoginParams(email: event.email, password: event.password);

    final result = await _authUseCases.login(params);

    result.fold(
          (failure) {
        if (failure is InvalidAuthDataFailure) {
          emit(LoginFormValidationError(failure.errors));
        } else {
          emit(
            LoginError(
              message: failure.message,
              statusCode: failure.statusCode,
            ),
          );
        }
      },
          (authResponse) {
        _user = authResponse;
        emit(LoginLoaded(authResponse: authResponse));

        // Save credentials if remember me is checked
        if (event.rememberMe) {
          saveUserCredentials(event.email, event.password);
        }
      },
    );
  }

  Future<void> _onLogout(LoginEventLogout event,
      Emitter<LoginState> emit) async {
    if (_user == null) return;

    emit(const LogoutLoading());

    final result = await _authUseCases.logout(NoParams());

    result.fold(
          (failure) {
        if (failure.statusCode == 500) {
          // Handle server error but still logout locally
          _performLocalLogout();
          emit(const LogoutLoaded(message: 'Logout successful'));
        } else {
          emit(
            LogoutError(
              message: failure.message,
              statusCode: failure.statusCode,
            ),
          );
        }
      },
          (message) {
        _performLocalLogout();
        emit(LogoutLoaded(message: message));
      },
    );
  }

  /// Handles session expiry (triggered by the [AuthInterceptor] when refresh
  /// fails).
  Future<void> _onSessionExpired(
    LoginEventSessionExpired event,
    Emitter<LoginState> emit,
  ) async {
    _performLocalLogout();
    emit(SessionExpired(
      message: event.message ?? 'Session expired. Please login again.',
    ));
  }

  /// Clean up local state on logout / session expiry.
  void _performLocalLogout() {
    _user = null;
    removeCredentials();
    TokenManager.instance.clearTokens();
    DioClient.reset();
  }
}

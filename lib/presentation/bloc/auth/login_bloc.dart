import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/auth_response.dart';
import '../../../domain/usecases/auth/get_existing_user_info_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../data/models/errors/errors_model.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetExistingUserInfoUseCase _getExistingUserInfoUseCase;

  AuthResponse? _user;

  bool get isLoggedIn => _user != null && _user!.accessToken.isNotEmpty;
  AuthResponse? get userInformation => _user;
  set saveUserData(AuthResponse userData) => _user = userData;

  LoginBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetExistingUserInfoUseCase getExistingUserInfoUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _getExistingUserInfoUseCase = getExistingUserInfoUseCase,
       super(const LoginInitial()) {
    on<LoginEventSubmit>(_onLoginSubmit);
    on<LoginEventLogout>(_onLogout);

    // Load existing user info on initialization
    _loadExistingUser();
  }

  void _loadExistingUser() {
    final result = _getExistingUserInfoUseCase(NoParams());
    result.fold((failure) => _user = null, (success) {
      saveUserData = success;
      log('Existing user loaded: $success', name: 'saved-user-data');
    });
  }

  Future<void> saveUserCredentials(String email, String password) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', email);
    pref.setString('password', password);
  }

  Future<void> removeCredentials() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('email');
    pref.remove('password');
  }

  Future<void> _onLoginSubmit(
    LoginEventSubmit event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final params = LoginParams(email: event.email, password: event.password);

    final result = await _loginUseCase(params);

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

  Future<void> _onLogout(
    LoginEventLogout event,
    Emitter<LoginState> emit,
  ) async {
    if (_user == null) return;

    emit(const LogoutLoading());

    final params = LogoutParams(token: _user!.accessToken);
    final result = await _logoutUseCase(params);

    result.fold(
      (failure) {
        if (failure.statusCode == 500) {
          // Handle server error but still logout locally
          _user = null;
          removeCredentials();
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
        _user = null;
        removeCredentials();
        emit(LogoutLoaded(message: message));
      },
    );
  }
}

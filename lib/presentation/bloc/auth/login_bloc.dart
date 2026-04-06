import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures/failures.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_manager.dart';
import '../../../data/mappers/auth/login_response_mapper.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';
import '../../../data/models/errors/errors_model.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, UserModel> {
  final AuthUseCases _authUseCases;

  LoginResponseModel? _user;

  bool get isLoggedIn => _user != null && (_user?.accessToken.isNotEmpty??false);

  LoginResponseModel? get userInformation => _user;

  set saveUserData(LoginResponseModel userData) => _user = userData;

  LoginBloc({required AuthUseCases authUseCases})
    : _authUseCases = authUseCases,
      super(const UserModel()) {
    on<LoginInfoAddEvent>(_onLoginInfoAddSubmit);
    on<LoginEventSubmit>(_onLoginSubmit);
    on<LoginEventLogout>(_onLogout);
    on<LoginEventSessionExpired>(_onSessionExpired);

    // Load existing user info on initialization
    _loadExistingUser();
  }

  void _onLoginInfoAddSubmit(LoginInfoAddEvent event,Emitter<UserModel> emit){

    final existing = state.userInfo ?? UserModel();
    final updated = event.addUserInfo(existing);

    emit(state.copyWith(userInfo: updated, loginState: LoginInitial()));
  }

  void _loadExistingUser() {
    final result = _authUseCases.getExistingUserInfo();
    result.fold((failure) => _user = null, (success) {
      //saveUserData = success?.toData() ?? null;
      log('Existing user loaded: $success', name: 'saved-user-data');
    });
  }

  // Future<void> saveUserCredentials(String email, String password) async {
  //   final params = CredentialsParams(email: email, password: password);
  //   await _authUseCases.saveCredentials(params);
  // }
  //
  // Future<void> removeCredentials() async {
  //   await _authUseCases.removeCredentials(NoParams());
  // }

  Future<void> _onLoginSubmit(LoginEventSubmit event, Emitter<UserModel> emit) async {
    emit(state.copyWith(loginState: const LoginLoading()));


    final result = await _authUseCases.login(state);

    result.fold((failure) {
        if (failure is InvalidAuthDataFailure) {
          final error = LoginFormValidationError(failure.errors);
          emit(state.copyWith(loginState: error));
        } else {
          final error = LoginError(message: failure.message, statusCode: failure.statusCode);
          emit(state.copyWith(loginState: error));
        }
      },
          (authResponse) {
        _user = authResponse?.toData();
        final loaded = LoginLoaded(authResponse: _user);
        emit(state.copyWith(loginState: loaded));

        // if (event.rememberMe) {
        //   saveUserCredentials(event.email, event.password);
        // }
      },
    );
  }

  Future<void> _onLogout(LoginEventLogout event, Emitter<UserModel> emit) async {

    if (_user == null) return;

    emit(state.copyWith(loginState: const LogoutLoading()));

    final result = await _authUseCases.logout();

    result.fold((failure) {
        if (failure.statusCode == 500) {
          // Handle server error but still logout locally
          _performLocalLogout();
          final error = const LogoutLoaded(message: 'Logout successful');
          emit(state.copyWith(loginState: error));
        } else {
          final error = LogoutError(message: failure.message, statusCode: failure.statusCode);
          emit(state.copyWith(loginState: error));
        }
      },(message) {
        _performLocalLogout();
        emit(state.copyWith(loginState: LogoutLoaded(message: message)));
      },
    );
  }

  /// Handles session expiry (triggered by the [AuthInterceptor] when refresh
  /// fails).
  Future<void> _onSessionExpired(LoginEventSessionExpired event, Emitter<UserModel> emit) async {
    _performLocalLogout();
    final error = SessionExpired(message: event.message ?? 'Session expired. Please login again.');
    emit(state.copyWith(loginState: error));
  }

  /// Clean up local state on logout / session expiry.
  void _performLocalLogout() {
    _user = null;
    // removeCredentials();
    TokenManager.instance.clearTokens();
    DioClient.reset();
  }
}

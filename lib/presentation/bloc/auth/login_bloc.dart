import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/failures/failures.dart';
import '../../../core/network/token_manager.dart';
import '../../../data/mappers/auth/login_response_mapper.dart';
import '../../../data/models/auth/login_response_model.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/models/errors/errors_model.dart';
import '../../../domain/usecases/auth/auth_usecases.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, UserModel> {
  final AuthUseCases _authUseCases;
  final TokenManager _tokenManager;
  late final StreamSubscription<TokenSnapshot> _tokenSubscription;

  LoginResponseModel? _user;

  bool get isLoggedIn => _user != null && (_user?.accessToken.isNotEmpty??false);

  LoginResponseModel? get userInformation => _user;

  set saveUserData(LoginResponseModel? userData) => _user = userData;

  LoginBloc({
    required AuthUseCases authUseCases,
    TokenManager? tokenManager,
  })
    : _authUseCases = authUseCases,
      _tokenManager = tokenManager ?? TokenManager.instance,
      super(const UserModel()) {
    on<LoginInfoAddEvent>(_onLoginInfoAddSubmit);
    on<LoginEventSubmit>(_onLoginSubmit);
    on<LoginEventLogout>(_onLogout);
    on<LoginEventSessionExpired>(_onSessionExpired);
    on<LoginEventTokensUpdated>(_onTokensUpdated);

    // Load existing user info on initialization
    _loadExistingUser();
    _tokenSubscription = _tokenManager.tokenChanges.listen(_onTokenChanged);
  }

  void _onTokenChanged(TokenSnapshot snapshot) {
    if (_user == null) return;
    final accessToken = snapshot.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;
    add(LoginEventTokensUpdated(
      accessToken: accessToken,
      refreshToken: snapshot.refreshToken,
    ));
  }

  void _onTokensUpdated(LoginEventTokensUpdated event, Emitter<UserModel> emit) {
    if (_user == null) return;
    _user = _user!.copyWith(
      accessToken: event.accessToken,
      refreshToken: event.refreshToken ?? _user!.refreshToken,
    );
    emit(state.copyWith(loginState: LoginLoaded(authResponse: _user)));
  }

  void _onLoginInfoAddSubmit(LoginInfoAddEvent event,Emitter<UserModel> emit){

    final existing = state.userInfo ?? UserModel();
    final updated = event.addUserInfo(existing);
    emit(state.copyWith(userInfo: updated,loginState: LoginInitial()));
  }

  Future<void> _loadExistingUser() async {
    final result = _authUseCases.getExistingUserInfo();
    await result.fold(
      (failure) async => _user = null,
      (success) async {
        final cachedUser = success?.toData();
        saveUserData = cachedUser;
        log('Existing user loaded: $cachedUser', name: 'saved-user-data');

        if (cachedUser != null && cachedUser.accessToken.isNotEmpty) {
          await _tokenManager.saveTokens(
            accessToken: cachedUser.accessToken,
            refreshToken: cachedUser.refreshToken,
          );
        }
      },
    );
  }

  // void updateExistingToken(LoginResponseModel ? model) {
  //   final result = _authUseCases.getExistingUserInfo();
  //   result.fold((failure) => _user = null, (success) {
  //     model = success?.toData();
  //     saveUserData = model;
  //     log('saved-new-info: $model', name: 'new-info-saved');
  //   });
  // }

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
  }

  @override
  Future<void> close() {
    _tokenSubscription.cancel();
    return super.close();
  }
}

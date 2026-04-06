import 'package:dartz/dartz.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/models/auth/user_register_model.dart';
import '../../entities/auth/login_response_entity.dart';
import '../../repositories/auth_repository.dart';

// =============================================
// AUTHENTICATION USE CASES COLLECTION
// =============================================

/// Login Use Case
class LoginUseCase implements UseCase<LoginResponseEntity?, UserModel?> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity?>> call(UserModel? params) async {
    return await repository.login(params);
  }
}

/// Logout Use Case — no longer requires a token parameter since the
/// [AuthInterceptor] attaches it automatically.
class LogoutUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call([NoParams? params]) async {
    return await repository.logout();
  }
}

/// Refresh Token Use Case
class RefreshTokenUseCase implements UseCase<LoginResponseEntity?, UserModel?> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity?>> call(UserModel? params) async {
    return await repository.refreshToken(params);
  }
}

/// Get Existing User Info Use Case (Sync)
class GetExistingUserInfoUseCase implements SyncUseCase<LoginResponseEntity?, NoParams> {
  final AuthRepository repository;

  GetExistingUserInfoUseCase(this.repository);

  @override
  Either<Failure, LoginResponseEntity?> call([NoParams? params]) {
    return repository.getExistingUserInfo();
  }
}

/// Register Use Case (Future extension)
class RegisterUseCase implements UseCase<LoginResponseEntity?, UserRegisterModel?> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity?>> call(UserRegisterModel? params) async {
    return await repository.register(params);
  }
}

/// Forgot Password Use Case
class ForgotPasswordUseCase implements UseCase<LoginResponseEntity?, UserRegisterModel?> {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity?>> call(UserRegisterModel? params) async {
    return await repository.forgotPassword(params);
  }
}

/// Reset Password Use Case
class ResetPasswordUseCase implements UseCase<LoginResponseEntity?, UserRegisterModel?> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity?>> call(UserRegisterModel? params) async {
    return await repository.resetPassword(params);
  }
}


// =============================================
// AUTH USE CASES COLLECTION CLASS
// =============================================

/// Centralized collection of all auth-related use cases
class AuthUseCases {
  final LoginUseCase login;
  final LogoutUseCase logout;
  final RefreshTokenUseCase refreshToken;
  final GetExistingUserInfoUseCase getExistingUserInfo;
  final RegisterUseCase register;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;

  AuthUseCases({
    required this.login,
    required this.logout,
    required this.refreshToken,
    required this.getExistingUserInfo,
    required this.register,
    required this.forgotPassword,
    required this.resetPassword,
  });

  /// Factory constructor for easy creation
  factory AuthUseCases.create(AuthRepository repository) {
    return AuthUseCases(
      login: LoginUseCase(repository),
      logout: LogoutUseCase(repository),
      refreshToken: RefreshTokenUseCase(repository),
      getExistingUserInfo: GetExistingUserInfoUseCase(repository),
      register: RegisterUseCase(repository),
      forgotPassword: ForgotPasswordUseCase(repository),
      resetPassword: ResetPasswordUseCase(repository),
    );
  }
}

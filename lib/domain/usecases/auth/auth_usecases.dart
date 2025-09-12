import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

// =============================================
// AUTHENTICATION USE CASES COLLECTION
// =============================================

/// Login Use Case
class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Logout Use Case
class LogoutUseCase implements UseCase<String, LogoutParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(LogoutParams params) async {
    return await repository.logout(params.token);
  }
}

/// Get Existing User Info Use Case (Sync)
class GetExistingUserInfoUseCase implements SyncUseCase<AuthResponse, NoParams> {
  final AuthRepository repository;

  GetExistingUserInfoUseCase(this.repository);

  @override
  Either<Failure, AuthResponse> call(NoParams params) {
    return repository.getExistingUserInfo();
  }
}

/// Save Credentials Use Case
class SaveCredentialsUseCase implements UseCase<void, CredentialsParams> {
  final AuthRepository repository;

  SaveCredentialsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CredentialsParams params) async {
    return await repository.saveCredentials(
      email: params.email,
      password: params.password,
    );
  }
}

/// Remove Credentials Use Case
class RemoveCredentialsUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  RemoveCredentialsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.removeCredentials();
  }
}

/// Register Use Case (Future extension)
class RegisterUseCase implements UseCase<AuthResponse, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}

/// Forgot Password Use Case
class ForgotPasswordUseCase implements UseCase<String, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ForgotPasswordParams params) async {
    return await repository.forgotPassword(email: params.email);
  }
}

/// Reset Password Use Case
class ResetPasswordUseCase implements UseCase<String, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      email: params.email,
      token: params.token,
      password: params.password,
    );
  }
}

/// Update Profile Use Case
class UpdateProfileUseCase implements UseCase<AuthResponse, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      phone: params.phone,
      image: params.image,
    );
  }
}

// =============================================
// PARAMETERS CLASSES
// =============================================

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutParams extends Equatable {
  final String token;

  const LogoutParams({required this.token});

  @override
  List<Object> get props => [token];
}

class CredentialsParams extends Equatable {
  final String email;
  final String password;

  const CredentialsParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, phone];
}

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String token;
  final String password;

  const ResetPasswordParams({
    required this.email,
    required this.token,
    required this.password,
  });

  @override
  List<Object> get props => [email, token, password];
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? phone;
  final String? image;

  const UpdateProfileParams({
    this.name,
    this.phone,
    this.image,
  });

  @override
  List<Object?> get props => [name, phone, image];
}

// =============================================
// AUTH USE CASES COLLECTION CLASS
// =============================================

/// Centralized collection of all auth-related use cases
class AuthUseCases {
  final LoginUseCase login;
  final LogoutUseCase logout;
  final GetExistingUserInfoUseCase getExistingUserInfo;
  final SaveCredentialsUseCase saveCredentials;
  final RemoveCredentialsUseCase removeCredentials;
  final RegisterUseCase register;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;
  final UpdateProfileUseCase updateProfile;

  AuthUseCases({
    required this.login,
    required this.logout,
    required this.getExistingUserInfo,
    required this.saveCredentials,
    required this.removeCredentials,
    required this.register,
    required this.forgotPassword,
    required this.resetPassword,
    required this.updateProfile,
  });

  /// Factory constructor for easy creation
  factory AuthUseCases.create(AuthRepository repository) {
    return AuthUseCases(
      login: LoginUseCase(repository),
      logout: LogoutUseCase(repository),
      getExistingUserInfo: GetExistingUserInfoUseCase(repository),
      saveCredentials: SaveCredentialsUseCase(repository),
      removeCredentials: RemoveCredentialsUseCase(repository),
      register: RegisterUseCase(repository),
      forgotPassword: ForgotPasswordUseCase(repository),
      resetPassword: ResetPasswordUseCase(repository),
      updateProfile: UpdateProfileUseCase(repository),
    );
  }
}

import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../data/models/auth/user_model.dart';
import '../../data/models/auth/user_register_model.dart';
import '../entities/auth/login_response_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure, LoginResponseEntity?>> login(UserModel? params);

  /// Logs the user out (token is auto-attached by the interceptor).
  Future<Either<Failure, String>> logout();

  Either<Failure, LoginResponseEntity?> getExistingUserInfo();


  /// Refreshes the access token using the stored refresh token.
  Future<Either<Failure, LoginResponseEntity?>> refreshToken(UserModel? params);

  // Future authentication methods (for extensibility)
  Future<Either<Failure, LoginResponseEntity?>> register(UserRegisterModel? body);

  Future<Either<Failure, LoginResponseEntity?>> forgotPassword(UserRegisterModel? body);

  Future<Either<Failure, LoginResponseEntity?>> resetPassword(UserRegisterModel? body);

}

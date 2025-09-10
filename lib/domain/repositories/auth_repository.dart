import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> logout(String token);

  Either<Failure, AuthResponse> getExistingUserInfo();
}

import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> logout(String token);

  Either<Failure, AuthResponse> getExistingUserInfo();
  
  Future<Either<Failure, void>> saveCredentials({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, void>> removeCredentials();
  
  // Future authentication methods (for extensibility)
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  
  Future<Either<Failure, String>> forgotPassword({required String email});
  
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String password,
  });
  
  Future<Either<Failure, AuthResponse>> updateProfile({
    String? name,
    String? phone,
    String? image,
  });
}

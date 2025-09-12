import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/exceptions.dart';
import '../data_provider/local_data_source.dart';
import '../data_provider/remote_data_source.dart';
import '../mappers/auth_mappers.dart';
import '../models/auth/login_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSources;
  final LocalDataSource localDataSources;

  AuthRepositoryImpl({
    required this.remoteDataSources,
    required this.localDataSources,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginModel = LoginModel(email: email, password: password);
      final result = await remoteDataSources.login(loginModel);
      localDataSources.cacheUserResponse(result);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on InvalidAuthDataException catch (e) {
      return Left(InvalidAuthDataFailure(e.errors));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred', 500));
    }
  }

  @override
  Either<Failure, AuthResponse> getExistingUserInfo() {
    try {
      final result = localDataSources.getExistingUserInfo();
      return Right(result.toDomain());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user info'));
    }
  }

  @override
  Future<Either<Failure, String>> logout(String token) async {
    try {
      final logout = await remoteDataSources.logout(token);
      localDataSources.clearUserResponse();
      return Right(logout);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to logout', 500));
    }
  }

  @override
  Future<Either<Failure, void>> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await localDataSources.saveCredentials(email: email, password: password);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to save credentials'));
    }
  }

  @override
  Future<Either<Failure, void>> removeCredentials() async {
    try {
      await localDataSources.removeCredentials();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to remove credentials'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // TODO: Implement actual register API call
      // For now, return a placeholder implementation
      return Left(ServerFailure('Register not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Registration failed', 500));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({required String email}) async {
    try {
      // TODO: Implement actual forgot password API call
      // For now, return a placeholder implementation
      return Left(ServerFailure('Forgot password not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Forgot password failed', 500));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      // TODO: Implement actual reset password API call
      // For now, return a placeholder implementation
      return Left(ServerFailure('Reset password not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Reset password failed', 500));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> updateProfile({
    String? name,
    String? phone,
    String? image,
  }) async {
    try {
      // TODO: Implement actual update profile API call
      // For now, return a placeholder implementation
      return Left(ServerFailure('Update profile not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Update profile failed', 500));
    }
  }
}

import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../core/network/token_manager.dart';
import '../../domain/entities/auth/login_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/exceptions.dart';
import '../data_provider/local_data_source.dart';
import '../data_provider/remote_data_source.dart';
import '../mappers/auth/login_response_mapper.dart';
import '../models/auth/login_response_model.dart';
import '../models/auth/user_model.dart';
import '../models/auth/user_register_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSources;
  final LocalDataSource localDataSources;
  final TokenManager tokenManager;

  AuthRepositoryImpl({required this.remoteDataSources, required this.localDataSources, required this.tokenManager});

  @override
  Future<Either<Failure, LoginResponseEntity?>> login(UserModel? body) async {
    try {

      final result = await remoteDataSources.login(body);

      // Safe null check
      if(result == null) return Right(null);

      final loginResponse = LoginResponseModel.fromMap(result).toDomain();

      // Cache user info locally
      await localDataSources.cacheUserResponse(loginResponse.toData());

      // Save tokens securely for the interceptor
      await tokenManager.saveTokens(
        accessToken: loginResponse.accessToken??'',
        refreshToken: loginResponse.refreshToken??'',
      );

      return Right(loginResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on InvalidAuthDataException catch (e) {
      return Left(InvalidAuthDataFailure(e.errors));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred', 500));
    }
  }


  @override
  Either<Failure, LoginResponseEntity?> getExistingUserInfo() {
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
  Future<Either<Failure, String>> logout() async {
    try {
      final logout = await remoteDataSources.logout();
      await localDataSources.clearUserResponse();
      await tokenManager.clearTokens();
      return Right(logout is String ? logout : 'Logged out successfully');
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to logout', 500));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity?>> refreshToken(UserModel? params) async {
    try {
      final currentRefreshToken = await tokenManager.refreshToken;

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        return Left(ServerFailure('No refresh token available', 401));
      }

      final result = await remoteDataSources.refreshToken(currentRefreshToken);



      final loginResponse = LoginResponseModel.fromMap(result['data']).toDomain();

      // Update cached user info
      await localDataSources.cacheUserResponse(loginResponse.toData());

      // Save new tokens
      await tokenManager.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken.isNotEmpty
            ? loginResponse.refreshToken
            : currentRefreshToken,
      );

      return Right(loginResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Token refresh failed', 500));
    }
  }

 /* @override
  Future<Either<Failure, void>> saveCredentials(
      {required String email, required String password}) async {
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
*/

  @override
  Future<Either<Failure, LoginResponseEntity?>> register(UserRegisterModel? body) async {
    try {
      return Left(ServerFailure('Register not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Registration failed', 500));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity?>> forgotPassword(UserRegisterModel? body) async {
    try {
      return Left(ServerFailure('Forgot password not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Forgot password failed', 500));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity?>> resetPassword(UserRegisterModel? body) async {
    try {
      return Left(ServerFailure('Reset password not implemented yet', 501));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Reset password failed', 500));
    }
  }
}

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/exceptions/exception.dart';
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
}

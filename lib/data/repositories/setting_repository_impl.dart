import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../core/exceptions/exceptions.dart';
import '../data_provider/local_data_source.dart';
import '../data_provider/remote_data_source.dart';

class SettingRepositoryImpl implements SettingRepository {
  final RemoteDataSource remoteDataSources;
  final LocalDataSource localDataSources;

  SettingRepositoryImpl({
    required this.remoteDataSources,
    required this.localDataSources,
  });

  @override
  Future<Either<Failure, dynamic>> getSetting() async {
    try {
      final result = await remoteDataSources.getSetting();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to get settings', 500));
    }
  }
}

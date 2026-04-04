import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../domain/entities/setting/setting_entity.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../core/exceptions/exceptions.dart';
import '../data_provider/local_data_source.dart';
import '../data_provider/remote_data_source.dart';
import '../mappers/setting/setting_mapper.dart';
import '../models/setting/setting_model.dart';

class SettingRepositoryImpl implements SettingRepository {
  final RemoteDataSource remoteDataSources;
  final LocalDataSource localDataSources;

  SettingRepositoryImpl({
    required this.remoteDataSources,
    required this.localDataSources,
  });

  @override
  Future<Either<Failure, SettingEntity?>> getSetting() async {
    try {
      final result = await remoteDataSources.getSetting();

      final data = result;

      if (data == null) return Right(null);

      final model = SettingModel.fromMap(data).toDomain();

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on InvalidAuthDataException catch (e) {
      return Left(InvalidAuthDataFailure(e.errors));
    }
  }
}

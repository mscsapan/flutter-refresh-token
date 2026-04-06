import 'package:dartz/dartz.dart';

import '../../core/exceptions/exceptions.dart';
import '../../core/failures/failures.dart';
import '../../domain/entities/home/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_provider/remote_data_source.dart';
import '../mappers/home/home_mapper.dart';
import '../models/home/home_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final RemoteDataSource remoteDataSources;

  HomeRepositoryImpl({required this.remoteDataSources});

  @override
  Future<Either<Failure, List<HomeEntity?>?>> getHome() async{

    try {
      final result =  await remoteDataSources.getHome();

      // ✅ Null-check raw result
      if (result == null) return const Right(<HomeEntity>[]);

      // ✅ Safe extraction & cast of 'data'
      final items = result['todo'] as List<dynamic>? ?? <dynamic>[];

      // ✅ Safe mapping to models (with null filtering)
      final products = items.where((dynamic e) => e != null).map((dynamic e) => HomeModel.fromMap(e as Map<String, dynamic>? ?? <String, dynamic>{})).whereType<HomeModel>().toList();

      // ✅ Convert models → domain entities
      final productsEntity = products.map((HomeModel model) => model.toDomain()).toList();

      // ✅ Return empty list instead of null for consistency
      return Right(productsEntity.isEmpty ? <HomeEntity>[] : productsEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}

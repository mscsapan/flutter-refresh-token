import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/home/home_entity.dart';
import '../entities/setting/setting_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HomeEntity?>?>> getHome();
}

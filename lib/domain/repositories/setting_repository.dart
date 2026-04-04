import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/setting/setting_entity.dart';

abstract class SettingRepository {
  Future<Either<Failure, SettingEntity?>> getSetting();
}

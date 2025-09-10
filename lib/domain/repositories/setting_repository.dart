import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';

abstract class SettingRepository {
  Future<Either<Failure, dynamic>> getSetting();
}

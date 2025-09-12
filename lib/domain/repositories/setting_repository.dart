import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';

abstract class SettingRepository {
  Future<Either<Failure, dynamic>> getSetting();
}

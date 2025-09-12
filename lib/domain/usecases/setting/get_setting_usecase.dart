import 'package:dartz/dartz.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/setting_repository.dart';

class GetSettingUseCase implements UseCase<dynamic, NoParams> {
  final SettingRepository repository;

  GetSettingUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(NoParams params) async {
    return await repository.getSetting();
  }
}

import 'package:dartz/dartz.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/setting/setting_entity.dart';
import '../../repositories/setting_repository.dart';

class GetSettingUseCase implements OptionalParamUseCase<SettingEntity?, NoParams> {
  final SettingRepository repository;

  GetSettingUseCase(this.repository);

  @override
  Future<Either<Failure, SettingEntity?>> call([NoParams? params]) async {
    return await repository.getSetting();
  }

  // Onboarding related methods - not part of UseCase interface
  Future<Either<Failure, bool>> cachedOnBoarding() async {
    return await repository.cachedOnBoarding();
  }

  Either<Failure, bool> checkOnBoarding() {
    return repository.checkOnBoarding();
  }
}

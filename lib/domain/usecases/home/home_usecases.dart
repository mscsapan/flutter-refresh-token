import 'package:dartz/dartz.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/home/home_entity.dart';
import '../../entities/setting/setting_entity.dart';
import '../../repositories/home_repository.dart';
import '../../repositories/setting_repository.dart';

class HomeUseCase implements UseCase<List<HomeEntity?>?, NoParams> {
  final HomeRepository repository;

  HomeUseCase(this.repository);

  @override
  Future<Either<Failure, List<HomeEntity?>?>> call([NoParams? params]) async {
    return await repository.getHome();
  }
}

class HomeDataUseCases {
  final HomeUseCase homeUseCase;

  HomeDataUseCases({required this.homeUseCase});

  /// Factory constructor for easy creation
  factory HomeDataUseCases.create(HomeRepository repository) {
    return HomeDataUseCases(homeUseCase: HomeUseCase(repository));
  }
}

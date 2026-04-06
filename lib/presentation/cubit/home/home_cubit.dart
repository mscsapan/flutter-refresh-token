import 'package:bloc/bloc.dart';
import 'package:bloc_clean_architecture/data/mappers/home/home_mapper.dart';
import 'package:bloc_clean_architecture/data/models/home/home_model.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/usecases/home/home_usecases.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeDataUseCases _useCase;

  HomeCubit({required HomeDataUseCases userCase})
    : _useCase = userCase,
      super(HomeInitial());

  Future<void> getSetting() async {
    emit(HomeLoading());

    final result = await _useCase.homeUseCase();

    result.fold(
      (failure) {
        // debugPrint('error code ${failure.statusCode} - ${failure.message}');
        final errors = HomeError(failure.message, failure.statusCode);
        emit(errors);
      },
      (settings) {
        final home = settings?.map((e) => e?.toData()).toList();
        emit(HomeLoaded(home));
      },
    );
  }
}

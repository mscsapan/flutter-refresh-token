import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mappers/setting/setting_mapper.dart';
import '../../../domain/usecases/setting/get_setting_usecase.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final GetSettingUseCase _useCase;

  SettingCubit({required GetSettingUseCase getSettingUseCase})
    : _useCase = getSettingUseCase,
      super(SettingInitial());

  bool get showOnBoarding => _useCase.checkOnBoarding().fold((l) => false, (r) => true);

  Future<void> cacheOnBoarding() async {
    final result = await _useCase.cachedOnBoarding();
    result.fold((l) => false, (r) => r);
  }

  Future<void> getSetting() async {
    emit(SettingLoading());

    final result = await _useCase();

    result.fold(
      (failure){
        // debugPrint('error code ${failure.statusCode} - ${failure.message}');
        final errors = SettingError(message: failure.message, statusCode: failure.statusCode);
        emit(errors);
      },
      (settings) => emit(SettingLoaded(settings?.toData())),
    );
  }
}

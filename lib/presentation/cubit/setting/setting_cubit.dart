import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/setting/get_setting_usecase.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final GetSettingUseCase _getSettingUseCase;

  SettingCubit({required GetSettingUseCase getSettingUseCase})
    : _getSettingUseCase = getSettingUseCase,
      super(SettingInitial());

  Future<void> getSetting() async {
    emit(SettingLoading());

    final result = await _getSettingUseCase();

    result.fold(
      (failure) => emit(
        SettingError(message: failure.message, statusCode: failure.statusCode),
      ),
      (settings) => emit(SettingLoaded(settings: settings)),
    );
  }
}

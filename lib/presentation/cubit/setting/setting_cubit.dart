import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mappers/setting/setting_mapper.dart';
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
      (failure){
        // debugPrint('error code ${failure.statusCode} - ${failure.message}');
        final errors = SettingError(message: failure.message, statusCode: failure.statusCode);
        emit(errors);
      },
      (settings) => emit(SettingLoaded(settings?.toData())),
    );
  }
}

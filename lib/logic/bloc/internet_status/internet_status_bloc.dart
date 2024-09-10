import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'internet_status_event.dart';
part 'internet_status_state.dart';

class InternetStatusBloc
    extends Bloc<InternetStatusEvent, InternetStatusState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  InternetStatusBloc() : super(InternetStatusInitial()) {
    on<InternetStatusBackEvent>((event, emit) =>
        emit(const InternetStatusBackState('Your internet was restored')));
    on<InternetStatusLostEvent>((event, emit) =>
        emit(const InternetStatusLostState('No internet connection')));
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        add(InternetStatusBackEvent());
      } else {
        add(InternetStatusLostEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _subscription!.cancel();
    return super.close();
  }
}

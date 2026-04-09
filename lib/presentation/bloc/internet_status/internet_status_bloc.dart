import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'internet_status_event.dart';

part 'internet_status_state.dart';

class InternetStatusBloc extends Bloc<InternetStatusEvent, InternetStatusState> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;
  bool _hasBeenOffline = false;

  InternetStatusBloc() : super(InternetStatusInitial()) {
    on<InternetStatusBackEvent>((event, emit) =>
        emit(const InternetStatusBackState('Your internet was restored')));
    on<InternetStatusLostEvent>((event, emit) =>
        emit(const InternetStatusLostState('No internet connection')));

    _initialCheck();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _handleConnectivity(result);
    });
  }

  Future<void> _initialCheck() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = _hasInternet(connectivityResult);
    if (!_isOnline) {
      _hasBeenOffline = true;
      add(InternetStatusLostEvent());
    }
  }

  void _handleConnectivity(List<ConnectivityResult> result) {
    final currentlyOnline = _hasInternet(result);

    if (!currentlyOnline) {
      if (_isOnline) {
        _isOnline = false;
        _hasBeenOffline = true;
        add(InternetStatusLostEvent());
      }
      return;
    }

    if (!_isOnline && _hasBeenOffline) {
      _isOnline = true;
      _hasBeenOffline = false;
      add(InternetStatusBackEvent());
      return;
    }

    _isOnline = true;
  }

  bool _hasInternet(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
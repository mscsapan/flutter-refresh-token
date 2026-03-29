import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Dio interceptor that automatically **retries failed requests** when the
/// device regains network connectivity.
///
/// How it works:
/// 1. When a request fails due to a network error (timeout, connection error,
///    socket exception), instead of immediately propagating the error…
/// 2. It waits for [Connectivity] to report that the network is back.
/// 3. Then **retries** the original request up to [maxRetries] times.
/// 4. If all retries fail, the error is propagated as usual.
///
/// This interceptor is especially useful for pages that load data on init —
/// if the user's connection drops momentarily, the request automatically
/// succeeds once connectivity is restored, without the UI needing to know.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Connectivity connectivity;
  final int maxRetries;
  final Duration retryDelay;

  static const _tag = 'RetryInterceptor';

  /// Key used to track how many retries have been attempted for a request.
  static const _retryCountKey = 'retry_count';

  RetryInterceptor({
    required this.dio,
    required this.connectivity,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network-related errors
    if (!_isRetryableError(err)) {
      handler.next(err);
      return;
    }

    final currentRetry = err.requestOptions.extra[_retryCountKey] as int? ?? 0;

    if (currentRetry >= maxRetries) {
      log('Max retries ($maxRetries) reached — giving up', name: _tag);
      handler.next(err);
      return;
    }

    log(
      'Network error (attempt ${currentRetry + 1}/$maxRetries) — '
      'waiting for connectivity…',
      name: _tag,
    );

    // Wait for network to come back
    final hasConnection = await _waitForConnectivity();

    if (!hasConnection) {
      log('Timed out waiting for connectivity', name: _tag);
      handler.next(err);
      return;
    }

    // Add a small delay to allow the connection to stabilise
    await Future.delayed(retryDelay);

    // Retry the request
    try {
      log('Retrying request: ${err.requestOptions.path}', name: _tag);

      // Increment retry count
      err.requestOptions.extra[_retryCountKey] = currentRetry + 1;

      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      // If retry also fails, let the interceptor chain handle it
      // (this will come back to onError and retry again if under maxRetries)
      handler.next(retryErr);
    }
  }

  /// Returns `true` if [err] is a network-related error worth retrying.
  bool _isRetryableError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        // SocketException etc. are wrapped as 'unknown'
        return true;
      default:
        return false;
    }
  }

  /// Waits until the device has network connectivity, or times out after
  /// 30 seconds.
  Future<bool> _waitForConnectivity() async {
    // First check if we already have connectivity
    final currentResult = await connectivity.checkConnectivity();
    if (_hasConnection(currentResult)) return true;

    // Otherwise, wait for the connectivity stream to report a connection
    try {
      await connectivity.onConnectivityChanged
          .where((results) => _hasConnection(results))
          .first
          .timeout(const Duration(seconds: 30));
      return true;
    } on TimeoutException {
      return false;
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}

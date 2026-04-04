import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/exceptions/exceptions.dart';
import '../models/errors/errors_model.dart';

/// Centralised Dio response/error parser.
///
/// Call [DioNetworkParser.call] with a `Future<Response>` factory and receive
/// the decoded body on success, or a typed [Exception] on failure.
///
/// All HTTP-status-code semantics live here — repositories and data-sources
/// stay clean.
class DioNetworkParser {
  DioNetworkParser._();

  static const _tag = 'DioNetworkParser';

  // ---------------------------------------------------------------------------
  // Public entry-point
  // ---------------------------------------------------------------------------

  /// Executes [request] and translates every error type to our domain
  /// exceptions.
  ///
  /// Returns the decoded response body (`Map`, `List`, or `String` depending
  /// on the server response).
  static Future<dynamic> call(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleDioException(e);
    } on SocketException {
      log('SocketException', name: _tag);
      throw const NetworkException('No internet connection', 10061);
    } on FormatException {
      log('FormatException', name: _tag);
      throw const DataFormatException('Data format exception', 422);
    } on TimeoutException {
      log('TimeoutException', name: _tag);
      throw const NetworkException('Request timeout', 408);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Maps Dio-level exceptions (transport errors, server errors whose body we
  /// have) to domain exceptions.
  static Never _handleDioException(DioException e) {
    log('DioException type=${e.type} status=${e.response?.statusCode}', name: _tag);

    switch (e.type) {
      // Connection problems → NetworkException
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException('Request timeout', 408);

      case DioExceptionType.connectionError:
        throw const NetworkException('No internet connection', 10061);

      // Server returned an HTTP error response
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null) {
          _handleResponse(response); // will throw the appropriate domain exc.
        }
        throw FetchDataException(
          'Unexpected server error',
          e.response?.statusCode ?? 500,
        );

      // Request was cancelled
      case DioExceptionType.cancel:
        throw const NetworkException('Request cancelled', 0);

      // Anything else
      default:
        throw FetchDataException(
          e.message ?? 'Unknown network error',
          e.response?.statusCode ?? 666,
        );
    }
  }

  /// Maps an HTTP status code to a domain value or domain exception.
  ///
  /// Returns the decoded `data` for 2xx responses.
  /// Throws a typed exception for all error codes.
  static dynamic _handleResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if(kDebugMode){
      log('HTTP $statusCode', name: _tag);
      log('$data',name: _tag);
    }

    switch (statusCode) {
      // ── Success ────────────────────────────────────────────────────────────
      case >= 200 && < 300:
        return data;

      // ── Client errors ──────────────────────────────────────────────────────
      case 400:
        throw BadRequestException(_extractMessage(data), 400);

      case 401:
        throw UnauthorisedException(_extractMessage(data), 401);

      case 402:
        throw UnauthorisedException(_extractMessage(data), 402);

      case 403:
        throw UnauthorisedException(_extractMessage(data), 403);

      case 404:
        throw const UnauthorisedException('Resource not found', 404);

      case 405:
        throw const UnauthorisedException('Method not allowed', 405);

      case 408:
        throw const NetworkException('Request timeout', 408);

      case 415:
        throw const DataFormatException('Unsupported media type', 415);

      case 422:
        // Treat as validation errors — delegate to Errors model
        final errorsData = _extractValidationErrors(data);
        throw InvalidInputException(errorsData);

      // ── Server errors ──────────────────────────────────────────────────────
      case 500:
        throw const InternalServerException('Internal server error', 500);

      case 503:
        throw const NetworkException('Service unavailable', 503);

      // ── Catch-all ──────────────────────────────────────────────────────────
      default:
        throw FetchDataException(
          'Unexpected error communicating with server',
          statusCode,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Error message extraction helpers
  // ---------------------------------------------------------------------------

  /// Extracts a human-readable message from the response body.
  ///
  /// Checks `notification`, `message`, then falls back to a generic string.
  static String _extractMessage(dynamic data) {
    try {
      if (data is Map) {
        if (data['notification'] != null) return data['notification'].toString();
        if (data['message'] != null) return data['message'].toString();
      }
    } catch (e) {
      log('_extractMessage error: $e', name: _tag);
    }
    return 'Credentials do not match';
  }

  /// Extracts validation error fields from the response body for HTTP 422.
  ///
  /// Returns an [Errors] object populated from `data['errors']` if present,
  /// or from the top-level map if `errors` key is absent.
  static Errors _extractValidationErrors(dynamic data) {
    try {
      if (data is Map) {
        final errorsMap = data['errors'] as Map? ?? data;
        return Errors.fromMap(Map<String, dynamic>.from(errorsMap));
      }
    } catch (e) {
      log('_extractValidationErrors error: $e', name: _tag);
    }
    return Errors.fromMap({});
  }
}

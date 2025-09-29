import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../errors/app_exception.dart';
import '../errors/failures.dart';

class ErrorHandler {
  static AppException handleDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection.',
          code: 'CONNECTION_TIMEOUT',
        );
      case DioErrorType.sendTimeout:
        return const NetworkException(
          'Request timeout. Please try again.',
          code: 'SEND_TIMEOUT',
        );
      case DioErrorType.receiveTimeout:
        return const NetworkException(
          'Server response timeout. Please try again.',
          code: 'RECEIVE_TIMEOUT',
        );
      case DioErrorType.response:
        return _handleResponseError(error);
      case DioErrorType.cancel:
        return const NetworkException(
          'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );
      case DioErrorType.other:
        return const NetworkException(
          'No internet connection. Please check your network settings.',
          code: 'NO_INTERNET',
        );
      default:
        return const NetworkException(
          'An unexpected network error occurred.',
          code: 'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  static AppException _handleResponseError(DioError error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          _extractErrorMessage(data) ?? 'Invalid request. Please check your input.',
          code: 'BAD_REQUEST',
          details: data,
        );
      case 401:
        return const AuthException(
          'Authentication failed. Please login again.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const AuthException(
          'You don\'t have permission to perform this action.',
          code: 'FORBIDDEN',
        );
      case 404:
        return const ServerException(
          'The requested resource was not found.',
          code: 'NOT_FOUND',
        );
      case 422:
        return ValidationException(
          _extractErrorMessage(data) ?? 'Validation failed. Please check your input.',
          code: 'VALIDATION_ERROR',
          details: data,
        );
      case 500:
        return const ServerException(
          'Internal server error. Please try again later.',
          code: 'INTERNAL_SERVER_ERROR',
        );
      case 502:
        return const ServerException(
          'Server is temporarily unavailable. Please try again later.',
          code: 'BAD_GATEWAY',
        );
      case 503:
        return const ServerException(
          'Service is temporarily unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return ServerException(
          'Server error occurred (${statusCode ?? 'Unknown'}). Please try again.',
          code: 'SERVER_ERROR',
          details: data,
        );
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try different common error message fields
      return data['message'] ??
             data['error'] ??
             data['detail'] ??
             data['msg'];
    }
    return null;
  }

  static Failure exceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else {
      return ServerFailure(exception.message);
    }
  }

  static String getLocalizedErrorMessage(AppException exception, AppLocalizations l10n) {
    switch (exception.code) {
      case 'CONNECTION_TIMEOUT':
      case 'SEND_TIMEOUT':
      case 'RECEIVE_TIMEOUT':
        return 'Connection timeout. Please check your internet connection.';
      case 'NO_INTERNET':
        return 'No internet connection. Please check your network settings.';
      case 'UNAUTHORIZED':
        return 'Authentication failed. Please login again.';
      case 'FORBIDDEN':
        return 'You don\'t have permission to perform this action.';
      case 'VALIDATION_ERROR':
      case 'BAD_REQUEST':
        return 'Please check your input and try again.';
      case 'NOT_FOUND':
        return 'The requested resource was not found.';
      case 'INTERNAL_SERVER_ERROR':
      case 'BAD_GATEWAY':
      case 'SERVICE_UNAVAILABLE':
        return 'Server is temporarily unavailable. Please try again later.';
      default:
        return exception.message;
    }
  }
}
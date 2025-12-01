import 'package:dio/dio.dart';

abstract class AppFailure {
  const AppFailure(this.message);

  final String message;

  factory AppFailure.fromException(Object error) {
    if (error is AppFailure) {
      return error;
    }
    if (error is DioException) {
      if (_isNetworkError(error.type)) {
        return NetworkFailure(
          message: '네트워크 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        );
      }
      final statusCode = error.response?.statusCode;
      final responseMessage = _extractMessage(error);
      return ApiFailure(
        message: responseMessage ??
            '요청이 실패했습니다${statusCode != null ? ' (HTTP $statusCode)' : ''}.',
        statusCode: statusCode,
      );
    }
    return UnknownFailure(
      message: '알 수 없는 오류가 발생했습니다: $error',
    );
  }

  static bool _isNetworkError(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError;
  }

  static String? _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return error.message;
  }
}

class ApiFailure extends AppFailure {
  const ApiFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  final int? statusCode;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({required String message}) : super(message);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({required String message}) : super(message);
}

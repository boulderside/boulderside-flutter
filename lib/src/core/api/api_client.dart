import 'dart:convert';

import 'package:boulderside_flutter/src/core/api/api_config.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class ApiClient {
  ApiClient._();
  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    // 공통 인터셉터: Authorization 자동 주입
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final tokenStore = GetIt.I<TokenStore>();
          final accessToken = await tokenStore.getAccessToken();
          final isAuthRequest = o.path.contains('/login') || o.path.contains('/signup');
          if (!isAuthRequest && accessToken != null && o.headers['Authorization'] == null) {
            o.headers['Authorization'] = 'Bearer $accessToken';
          }
          h.next(o);
        },
        onError: (e, h) {
          // 로그인 전 단계라 리프레시는 생략
          // 필요시 여기서 공통 에러 처리만
          h.next(e);
        },
      ),
    );

    // 모든 API 요청/응답 로깅
    d.interceptors.add(_ApiLoggingInterceptor());

    return d;
  }
}

class _ApiLoggingInterceptor extends Interceptor {
  _ApiLoggingInterceptor();

  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─ API Request ─────────────────────────────')
      ..writeln('│ [${options.method}] ${options.uri}')
      ..writeln('│ Headers: ${_stringify(_sanitizeHeaders(options.headers))}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${_stringify(options.queryParameters)}');
    }
    if (options.data != null) {
      buffer.writeln('│ Body: ${_stringify(_normalizeData(options.data))}');
    }
    buffer.writeln('└────────────────────────────────────────────');
    debugPrint(buffer.toString());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─ API Response ────────────────────────────')
      ..writeln(
        '│ [${response.requestOptions.method}] ${response.requestOptions.uri}',
      )
      ..writeln('│ Status: ${response.statusCode}')
      ..writeln('│ Headers: ${_stringify(response.headers.map)}')
      ..writeln('│ Data: ${_stringify(response.data)}')
      ..writeln('└────────────────────────────────────────────');
    debugPrint(buffer.toString());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─ API Error ───────────────────────────────')
      ..writeln('│ [${err.requestOptions.method}] ${err.requestOptions.uri}')
      ..writeln('│ Message: ${err.message}');
    if (err.response != null) {
      buffer
        ..writeln('│ Status: ${err.response?.statusCode}')
        ..writeln('│ Data: ${_stringify(err.response?.data)}');
    }
    buffer.writeln('└────────────────────────────────────────────');
    debugPrint(buffer.toString());
    super.onError(err, handler);
  }

  String _stringify(dynamic data) {
    if (data == null) {
      return 'null';
    }
    try {
      return _encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  dynamic _normalizeData(dynamic data) {
    if (data is FormData) {
      final map = <String, dynamic>{
        'fields': data.fields,
        'files': data.files.map(
          (f) => {
            'key': f.key,
            'filename': f.value.filename,
            'contentType': f.value.contentType.toString(),
            'length': f.value.length,
          },
        ),
      };
      return map;
    }
    return data;
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final result = <String, dynamic>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization' && value is String) {
        result[key] = value.length <= 16
            ? '***'
            : '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}

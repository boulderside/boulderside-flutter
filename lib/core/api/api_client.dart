import 'package:boulderside_flutter/core/api/api_config.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:dio/dio.dart';

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

    // 공통 인터셉터: Authorization 자동 주입 + 간단 로깅
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final accessToken = await TokenStore.getAccessToken();
          if (accessToken != null && o.headers['Authorization'] == null) {
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

    return d;
  }
}

import 'dart:io';

class ApiConfig {
  static const String _defined = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_defined.isNotEmpty) return _defined;
    if (Platform.isAndroid)
      return 'http://10.0.2.2:8080/api'; // 안드로이드 에뮬레이터 -> Spring
    return 'http://localhost:8080/api'; // iOS 시뮬레이터/데스크톱 -> Spring
  }
}

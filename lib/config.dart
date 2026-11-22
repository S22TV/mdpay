import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    final v = dotenv.maybeGet('API_BASE_URL');
    if (v == null || v.isEmpty) {
      throw StateError('API_BASE_URL нь .env файлд тохируулагдаагүй байна');
    }
    return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
  }

  static String get mobileApiUrl => '$apiBaseUrl/api/mobile';
}

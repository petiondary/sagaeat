class ApiConfig {
  ApiConfig._();

  // URL otomatik selon anviwonman:
  //   flutter run                              → DEV (IP lokal)
  //   flutter build apk --dart-define=ENV=prod → PROD (api.sagaeat.ht)
  static const String _env     = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String _devUrl  = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.150.102:8000/api');
  static const String _prodUrl = 'https://api.sagaeat.ht/api';
  static const String baseUrl  = _env == 'prod' ? _prodUrl : _devUrl;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey  = 'auth_token';
  static const String userIdKey = 'user_id';
}

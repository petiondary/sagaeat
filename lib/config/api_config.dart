class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://api.sagaeat.ht/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
}

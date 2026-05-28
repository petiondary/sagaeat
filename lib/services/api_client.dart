import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = _build();
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Dio get dio => _dio;
  static FlutterSecureStorage get storage => _storage;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: ApiConfig.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401) {
            // Token expired — clear and signal unauthenticated
            await _storage.delete(key: ApiConfig.tokenKey);
            await _storage.delete(key: ApiConfig.userIdKey);
            // Screens observe `authStateNotifier` and redirect to login
            authStateNotifier.value = false;
          }
          handler.next(err);
        },
      ),
    );

    return dio;
  }

  // Reactive auth state — screens listen to redirect on 401
  static final _authState = AuthState();
  static AuthState get authStateNotifier => _authState;

  static Future<void> saveToken(String token) =>
      _storage.write(key: ApiConfig.tokenKey, value: token);

  static Future<void> clearSession() async {
    await _storage.delete(key: ApiConfig.tokenKey);
    await _storage.delete(key: ApiConfig.userIdKey);
    authStateNotifier.value = false;
  }

  static Future<bool> get hasToken async =>
      (await _storage.read(key: ApiConfig.tokenKey)) != null;
}

// Minimal ValueNotifier-like wrapper so screens can listen without flutter imports here
class AuthState {
  bool _value = true;
  final List<void Function(bool)> _listeners = [];

  bool get value => _value;
  set value(bool v) {
    _value = v;
    for (final l in _listeners) {
      l(v);
    }
  }

  void addListener(void Function(bool) listener) => _listeners.add(listener);
  void removeListener(void Function(bool) listener) => _listeners.remove(listener);
}

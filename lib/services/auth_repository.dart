import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthRepository {
  AuthRepository._();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await ApiClient.dio.post('/auth/customer/login', data: {
      'email': email,
      'password': password,
    });
    final token = resp.data['token'] as String;
    await ApiClient.saveToken(token);
    await ApiClient.storage.write(
      key: ApiConfig.userIdKey,
      value: resp.data['user']['id'].toString(),
    );
    ApiClient.authStateNotifier.value = true;
    return resp.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String birthDate,
    String department = '',
    String commune    = '',
    String city        = '',
    String houseDetails = '',
  }) async {
    final resp = await ApiClient.dio.post('/auth/customer/register', data: {
      'name':       name,
      'email':      email,
      'phone':      phone,
      'password':   password,
      'birth_date': birthDate,
      if (department.isNotEmpty || commune.isNotEmpty)
        'address': {
          'department':    department,
          'commune':       commune,
          'city':          city,
          'house_details': houseDetails,
        },
    });
    final token = resp.data['token'] as String;
    await ApiClient.saveToken(token);
    await ApiClient.storage.write(
      key: ApiConfig.userIdKey,
      value: resp.data['user']['id'].toString(),
    );
    ApiClient.authStateNotifier.value = true;
    return resp.data as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.dio.post('/auth/customer/logout');
    } on DioException {
      // Best-effort — clear locally regardless
    } finally {
      await ApiClient.clearSession();
    }
  }

  static Future<void> sendOtp(String email) async {
    await ApiClient.dio.post('/auth/send-otp', data: {'email': email});
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final resp = await ApiClient.dio.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
    });
    return resp.data['verified'] == true;
  }

  static Future<void> changePassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await ApiClient.dio.put('/auth/change-password', data: {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  // Returns the current user from the API (called once after login)
  static Future<UserModel> fetchMe() async {
    final resp = await ApiClient.dio.get('/user/profile');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }
}

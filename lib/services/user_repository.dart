import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class UserRepository {
  UserRepository._();

  static Future<UserModel> getProfile() async {
    final resp = await ApiClient.dio.get('/user/profile');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<UserModel> updateProfile({
    String? phone,
  }) async {
    final resp = await ApiClient.dio.put('/user/profile', data: {
      'phone': ?phone,
    });
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<String> uploadProfilePhoto(String filePath) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: 'photo.jpg'),
    });
    final resp = await ApiClient.dio.post('/user/profile-photo', data: form);
    return resp.data['photo_url'] as String;
  }

  static Future<List<ProfileAddress>> getAddresses() async {
    final resp = await ApiClient.dio.get('/user/addresses');
    return (resp.data as List<dynamic>)
        .map((a) => ProfileAddress.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  static Future<ProfileAddress> createAddress(ProfileAddress address) async {
    final resp = await ApiClient.dio.post('/user/addresses', data: address.toJson());
    return ProfileAddress.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<ProfileAddress> updateAddress(String id, ProfileAddress address) async {
    final resp = await ApiClient.dio.put('/user/addresses/$id', data: address.toJson());
    return ProfileAddress.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> deleteAddress(String id) async {
    await ApiClient.dio.delete('/user/addresses/$id');
  }
}

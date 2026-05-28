import '../data/restaurant_data.dart';
import 'api_client.dart';

class RestaurantRepository {
  RestaurantRepository._();

  static Future<List<RestaurantInfo>> getRestaurants({
    String? commune,
    int page = 1,
  }) async {
    final resp = await ApiClient.dio.get('/restaurants', queryParameters: {
      'commune': ?commune,
      'page': page,
    });
    return (resp.data['data'] as List<dynamic>)
        .map((r) => RestaurantInfo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static Future<RestaurantInfo> getRestaurant(int id) async {
    final resp = await ApiClient.dio.get('/restaurants/$id');
    return RestaurantInfo.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<List<Map<String, dynamic>>> getMenu(
    int restaurantId, {
    String? category,
  }) async {
    final resp = await ApiClient.dio.get(
      '/restaurants/$restaurantId/menu',
      queryParameters: {'category': ?category},
    );
    return (resp.data as List<dynamic>)
        .map((c) => Map<String, dynamic>.from(c as Map))
        .toList();
  }

  static Future<void> toggleFollow(int restaurantId) async {
    await ApiClient.dio.post('/restaurants/$restaurantId/follow');
  }
}

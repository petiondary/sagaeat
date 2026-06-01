import '../models/order_service.dart';
import 'api_client.dart';

class OrderRepository {
  OrderRepository._();

  static Future<OrderRecord> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String mode,
    required double subtotal,
    required double serviceFee,
    required double deliveryFee,
    required double couponDiscount,
    required double total,
    required String phone1,
    String? phone2,
    Map<String, dynamic>? deliveryAddress,
    String? couponCode,
    String paymentMethod = 'wallet',
  }) async {
    final resp = await ApiClient.dio.post('/orders', data: {
      'restaurant_id': restaurantId,
      'items': items,
      'mode': mode,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'delivery_fee': deliveryFee,
      'coupon_discount': couponDiscount,
      'total': total,
      'phone1': phone1,
      'payment_method': paymentMethod,
      if (phone2 != null) 'phone2': phone2,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (couponCode != null) 'coupon_code': couponCode,
    });
    return OrderRecord.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<List<OrderRecord>> getOrders({
    String? status,
    String? from,
    String? to,
    int page = 1,
  }) async {
    final resp = await ApiClient.dio.get('/orders', queryParameters: {
      'status': ?status,
      'from': ?from,
      'to': ?to,
      'page': page,
    });
    return (resp.data['data'] as List<dynamic>)
        .map((o) => OrderRecord.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  static Future<OrderRecord> getOrder(String id) async {
    final resp = await ApiClient.dio.get('/orders/$id');
    return OrderRecord.fromJson(resp.data as Map<String, dynamic>);
  }

  static Future<void> cancelOrder(String id) async {
    await ApiClient.dio.post('/orders/$id/cancel');
  }

  static Future<void> confirmPickup(String id) async {
    await ApiClient.dio.post('/orders/$id/confirm-pickup');
  }

  static Future<void> confirmDelivery(String id) async {
    await ApiClient.dio.post('/orders/$id/confirm-delivery');
  }

  static Future<Map<String, dynamic>> validateCoupon(
    String code,
    double cartTotal,
  ) async {
    final resp = await ApiClient.dio.post('/coupons/validate', data: {
      'code': code,
      'cart_total': cartTotal,
    });
    return resp.data as Map<String, dynamic>;
  }
}

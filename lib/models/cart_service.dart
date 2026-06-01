import 'package:flutter/material.dart';

class CartService {
  CartService._();

  static final List<Map<String, dynamic>> _items = [];
  static final ValueNotifier<int> countNotifier = ValueNotifier(0);

  static List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  // supplements: list of {name, price} maps
  static void add(
    Map<String, dynamic> product,
    int quantity,
    double total, {
    List<Map<String, dynamic>> supplements = const [],
  }) {
    final suppKey =
        supplements.map((s) => s['name'] as String).join('|');
    final idx = _items.indexWhere((i) =>
        i['name'] == product['name'] &&
        i['restaurant'] == product['restaurant'] &&
        i['_suppKey'] == suppKey);
    if (idx >= 0) {
      final newQty = (_items[idx]['quantity'] as int) + quantity;
      _items[idx]['quantity'] = newQty;
      _items[idx]['total'] = (_items[idx]['unitPrice'] as double) * newQty +
          (_items[idx]['suppTotal'] as double) * newQty;
    } else {
      final suppTotal =
          supplements.fold(0.0, (s, acc) => s + (acc['price'] as double));
      final unitPrice = (product['price'] as num).toDouble();
      _items.add({
        'name': product['name'] ?? '',
        'restaurant': product['restaurant'] ?? '',
        'restaurant_id': product['restaurant_id'],
        'menu_item_id': product['id'],
        'image': product['image'] ?? '',
        'unitPrice': unitPrice,
        'suppTotal': suppTotal,
        'quantity': quantity,
        'total': (unitPrice + suppTotal) * quantity,
        'supplements': List<Map<String, dynamic>>.from(supplements),
        '_suppKey': suppKey,
      });
    }
    _sync();
  }

  static void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      final unitPrice = _items[index]['unitPrice'] as double;
      final suppTotal = _items[index]['suppTotal'] as double? ?? 0.0;
      _items[index]['quantity'] = qty;
      _items[index]['total'] = (unitPrice + suppTotal) * qty;
    }
    _sync();
  }

  static void clear() {
    _items.clear();
    _sync();
  }

  static double get grandTotal =>
      _items.fold(0.0, (s, i) => s + (i['total'] as double));

  // Total delivery fee summed per unique restaurant from restaurant_data
  static double totalDeliveryFee(
      Set<String> pickupRestaurants,
      Map<String, double> restaurantFees) {
    final seen = <String>{};
    double total = 0;
    for (final item in _items) {
      final r = item['restaurant'] as String;
      if (seen.contains(r)) continue;
      seen.add(r);
      if (!pickupRestaurants.contains(r)) {
        total += restaurantFees[r] ?? 150.0;
      }
    }
    return total;
  }

  static void _sync() {
    countNotifier.value =
        _items.fold(0, (s, i) => s + (i['quantity'] as int));
  }
}

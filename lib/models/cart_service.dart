import 'package:flutter/material.dart';

class CartService {
  CartService._();

  static final List<Map<String, dynamic>> _items = [];
  static final ValueNotifier<int> countNotifier = ValueNotifier(0);

  static List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  static void add(Map<String, dynamic> product, int quantity, double total) {
    final idx = _items.indexWhere((i) => i['name'] == product['name']);
    if (idx >= 0) {
      final newQty = (_items[idx]['quantity'] as int) + quantity;
      _items[idx]['quantity'] = newQty;
      _items[idx]['total'] = (_items[idx]['unitPrice'] as double) * newQty;
    } else {
      _items.add({
        'name': product['name'] ?? '',
        'restaurant': product['restaurant'] ?? '',
        'image': product['image'] ?? '',
        'unitPrice': (product['price'] as num).toDouble(),
        'quantity': quantity,
        'total': total,
      });
    }
    _sync();
  }

  static void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index]['quantity'] = qty;
      _items[index]['total'] =
          (_items[index]['unitPrice'] as double) * qty;
    }
    _sync();
  }

  static void clear() {
    _items.clear();
    _sync();
  }

  static double get grandTotal =>
      _items.fold(0.0, (s, i) => s + (i['total'] as double));

  static void _sync() {
    countNotifier.value =
        _items.fold(0, (s, i) => s + (i['quantity'] as int));
  }
}

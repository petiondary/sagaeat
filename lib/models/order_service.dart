import 'package:flutter/foundation.dart';

class OrderRecord {
  final String orderId;
  final String restaurant;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double couponDiscount;
  final double total;
  final String mode; // 'pickup' | 'delivery'
  final DateTime createdAt;
  String status; // 'En cours' | 'En préparation' | 'En livraison' | 'Livré' | 'Annulé'
  DateTime? tsPreparation;
  DateTime? tsLivraison;
  DateTime? tsLivre;
  DateTime? tsAnnule;

  OrderRecord({
    required this.orderId,
    required this.restaurant,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.couponDiscount,
    required this.total,
    required this.mode,
    required this.createdAt,
    this.status = 'En cours',
    this.tsPreparation,
    this.tsLivraison,
    this.tsLivre,
    this.tsAnnule,
  });

  String get itemSummary {
    if (items.isEmpty) return '';
    final first = items.first['name'] as String;
    final extra = items.length - 1;
    if (extra == 0) return first;
    return '$first + $extra lòt pla';
  }
}

class OrderService {
  OrderService._();

  static final List<OrderRecord> _orders = [];
  static final ValueNotifier<int> countNotifier = ValueNotifier(0);

  static List<OrderRecord> get orders => List.unmodifiable(_orders);

  static void add(OrderRecord order) {
    _orders.insert(0, order);
    countNotifier.value = _orders.length;
  }

  static void updateStatus(String orderId, String newStatus,
      {DateTime? tsPreparation,
      DateTime? tsLivraison,
      DateTime? tsLivre,
      DateTime? tsAnnule}) {
    for (final o in _orders) {
      if (o.orderId == orderId) {
        o.status = newStatus;
        if (tsPreparation != null) o.tsPreparation = tsPreparation;
        if (tsLivraison != null) o.tsLivraison = tsLivraison;
        if (tsLivre != null) o.tsLivre = tsLivre;
        if (tsAnnule != null) o.tsAnnule = tsAnnule;
        countNotifier.value = _orders.length;
        return;
      }
    }
  }
}

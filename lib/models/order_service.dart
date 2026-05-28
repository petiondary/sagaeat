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

  factory OrderRecord.fromJson(Map<String, dynamic> j) => OrderRecord(
        orderId: j['id'].toString(),
        restaurant: j['restaurant'] as String? ?? '',
        items: (j['items'] as List<dynamic>? ?? [])
            .map((i) => Map<String, dynamic>.from(i as Map))
            .toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
        serviceFee: (j['service_fee'] as num? ?? 0).toDouble(),
        deliveryFee: (j['delivery_fee'] as num? ?? 0).toDouble(),
        couponDiscount: (j['coupon_discount'] as num? ?? 0).toDouble(),
        total: (j['total'] as num).toDouble(),
        mode: j['mode'] as String? ?? 'delivery',
        createdAt: DateTime.parse(j['created_at'] as String),
        status: j['status'] as String? ?? 'En cours',
        tsPreparation: j['ts_preparation'] != null
            ? DateTime.parse(j['ts_preparation'] as String)
            : null,
        tsLivraison: j['ts_livraison'] != null
            ? DateTime.parse(j['ts_livraison'] as String)
            : null,
        tsLivre: j['ts_livre'] != null
            ? DateTime.parse(j['ts_livre'] as String)
            : null,
        tsAnnule: j['ts_annule'] != null
            ? DateTime.parse(j['ts_annule'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': orderId,
        'restaurant': restaurant,
        'items': items,
        'subtotal': subtotal,
        'service_fee': serviceFee,
        'delivery_fee': deliveryFee,
        'coupon_discount': couponDiscount,
        'total': total,
        'mode': mode,
        'created_at': createdAt.toIso8601String(),
        'status': status,
        if (tsPreparation != null) 'ts_preparation': tsPreparation!.toIso8601String(),
        if (tsLivraison != null) 'ts_livraison': tsLivraison!.toIso8601String(),
        if (tsLivre != null) 'ts_livre': tsLivre!.toIso8601String(),
        if (tsAnnule != null) 'ts_annule': tsAnnule!.toIso8601String(),
      };

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

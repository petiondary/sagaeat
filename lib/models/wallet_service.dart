import 'package:flutter/material.dart';

class WalletTransaction {
  final String id;
  // deposit | purchase | refund | gift_card | transfer_out | transfer_in
  final String type;
  final double amount; // positive = credit, negative = debit
  final String description;
  final DateTime date;
  final String? orderId;
  final String? peer; // email/username for transfers

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.orderId,
    this.peer,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: j['id'].toString(),
        type: j['type'] as String,
        amount: (j['amount'] as num).toDouble(),
        description: j['description'] as String,
        date: DateTime.parse(j['created_at'] as String),
        orderId: j['order_id']?.toString(),
        peer: j['peer'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'description': description,
        'created_at': date.toIso8601String(),
        if (orderId != null) 'order_id': orderId,
        if (peer != null) 'peer': peer,
      };
}

class WalletService {
  WalletService._();

  static const double transferFee = 10.0;

  static final Map<String, double> _giftCardCodes = {
    'SAGA-1000-HTG': 1000.0,
    'SAGA-0500-HTG': 500.0,
    'SAGA-2500-HTG': 2500.0,
    'SAGA-5000-HTG': 5000.0,
    'DEMO-2026-XXX': 750.0,
  };
  static final Set<String> _usedGiftCards = {};

  static int _counter = 6;
  static String _genId() {
    _counter++;
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'TXN-$ts-$_counter';
  }

  static double _balance = 7500.0;
  static final ValueNotifier<double> balanceNotifier = ValueNotifier(_balance);

  static final List<WalletTransaction> _history = [
    WalletTransaction(
      id: 'TXN-001',
      type: 'deposit',
      amount: 5000.0,
      description: 'Depo via MonCash',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    WalletTransaction(
      id: 'TXN-002',
      type: 'purchase',
      amount: -850.0,
      description: 'Bouyon Tèt Chaje × 1',
      date: DateTime.now().subtract(const Duration(days: 4)),
      orderId: 'ORD-2026-1234',
    ),
    WalletTransaction(
      id: 'TXN-003',
      type: 'deposit',
      amount: 3000.0,
      description: 'Depo via Tranzak (Kaypa)',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WalletTransaction(
      id: 'TXN-004',
      type: 'refund',
      amount: 350.0,
      description: 'Ranbousman — Burger Kreyòl Anile',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      orderId: 'ORD-2026-0987',
    ),
    WalletTransaction(
      id: 'TXN-005',
      type: 'purchase',
      amount: -1200.0,
      description: 'Fritay Pwason Fre × 1',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      orderId: 'ORD-2026-8941',
    ),
    WalletTransaction(
      id: 'TXN-006',
      type: 'gift_card',
      amount: 1000.0,
      description: 'Gift Card — SAGA-1000-HTG',
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WalletTransaction(
      id: 'TXN-007',
      type: 'transfer_out',
      amount: -510.0,
      description: 'Transfere bay roselyne@gmail.com',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      peer: 'roselyne@gmail.com',
    ),
    WalletTransaction(
      id: 'TXN-008',
      type: 'transfer_in',
      amount: 800.0,
      description: 'Resivasyon transfere de jean.pierre',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      peer: 'jean.pierre',
    ),
  ];

  static List<WalletTransaction> get history =>
      List.unmodifiable(_history.reversed.toList().reversed.toList());
  static double get balance => _balance;
  static bool canPay(double amount) => _balance >= amount;

  static void deduct(double amount, {String description = 'Achat', String? orderId}) {
    _balance = (_balance - amount).clamp(0.0, double.infinity);
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: _genId(),
        type: 'purchase',
        amount: -amount,
        description: description,
        date: DateTime.now(),
        orderId: orderId,
      ),
    );
  }

  static void topUp(double amount, String method) {
    _balance += amount;
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: _genId(),
        type: 'deposit',
        amount: amount,
        description: 'Depo via $method',
        date: DateTime.now(),
      ),
    );
  }

  static void addRefund(double amount, String orderId, String itemName) {
    _balance += amount;
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: _genId(),
        type: 'refund',
        amount: amount,
        description: 'Ranbousman — $itemName Anile',
        date: DateTime.now(),
        orderId: orderId,
      ),
    );
  }

  /// Returns null on success, or an error key: 'invalid' | 'already_used'
  static String? redeemGiftCard(String code) {
    final upper = code.trim().toUpperCase();
    if (_usedGiftCards.contains(upper)) return 'already_used';
    final amount = _giftCardCodes[upper];
    if (amount == null) return 'invalid';
    _usedGiftCards.add(upper);
    _balance += amount;
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: _genId(),
        type: 'gift_card',
        amount: amount,
        description: 'Gift Card — $upper',
        date: DateTime.now(),
      ),
    );
    return null;
  }

  /// Returns the transfer ID on success, throws if insufficient balance.
  static String transferSend(double amount, String toUser) {
    final total = amount + transferFee;
    if (_balance < total) throw Exception('insufficient');
    _balance -= total;
    balanceNotifier.value = _balance;
    final txnId = _genId();
    _history.insert(
      0,
      WalletTransaction(
        id: txnId,
        type: 'transfer_out',
        amount: -total,
        description: 'Transfere bay $toUser',
        date: DateTime.now(),
        peer: toUser,
      ),
    );
    // Simulate the receiver's credit (same session, demo only)
    final rxId = _genId();
    _history.insert(
      1,
      WalletTransaction(
        id: rxId,
        type: 'transfer_in',
        amount: amount,
        description: 'Resivasyon transfere de mwen',
        date: DateTime.now(),
        peer: toUser,
      ),
    );
    return txnId;
  }

  /// Gift card codes exposed for QR simulation (demo)
  static List<String> get validGiftCardCodes =>
      _giftCardCodes.keys.where((k) => !_usedGiftCards.contains(k)).toList();
}

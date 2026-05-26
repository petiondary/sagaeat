import 'package:flutter/material.dart';

class WalletTransaction {
  final String id;
  final String type; // 'deposit' | 'purchase' | 'refund'
  final double amount; // positive = credit, negative = debit
  final String description;
  final DateTime date;
  final String? orderId;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.orderId,
  });
}

class WalletService {
  WalletService._();

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
      date: DateTime.now().subtract(const Duration(days: 1)),
      orderId: 'ORD-2026-0987',
    ),
    WalletTransaction(
      id: 'TXN-005',
      type: 'purchase',
      amount: -1200.0,
      description: 'Fritay Pwason Fre × 1',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      orderId: 'ORD-2026-8941',
    ),
  ];

  static List<WalletTransaction> get history => List.unmodifiable(_history);
  static double get balance => _balance;
  static bool canPay(double amount) => _balance >= amount;

  static void deduct(double amount, {String description = 'Achat'}) {
    _balance = (_balance - amount).clamp(0.0, double.infinity);
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        type: 'purchase',
        amount: -amount,
        description: description,
        date: DateTime.now(),
      ),
    );
  }

  static void topUp(double amount, String method) {
    _balance += amount;
    balanceNotifier.value = _balance;
    _history.insert(
      0,
      WalletTransaction(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
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
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        type: 'refund',
        amount: amount,
        description: 'Ranbousman — $itemName Anile',
        date: DateTime.now(),
        orderId: orderId,
      ),
    );
  }
}

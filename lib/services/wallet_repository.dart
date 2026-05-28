import '../models/wallet_service.dart';
import 'api_client.dart';

class WalletRepository {
  WalletRepository._();

  static Future<double> getBalance() async {
    final resp = await ApiClient.dio.get('/wallet');
    return (resp.data['balance'] as num).toDouble();
  }

  static Future<List<WalletTransaction>> getTransactions({
    String? type,
    String? from,
    String? to,
    int page = 1,
  }) async {
    final resp = await ApiClient.dio.get('/wallet/transactions', queryParameters: {
      'type': ?type,
      'from': ?from,
      'to': ?to,
      'page': page,
    });
    return (resp.data['data'] as List<dynamic>)
        .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  static Future<void> deposit(double amount, String method) async {
    await ApiClient.dio.post('/wallet/deposit', data: {
      'amount': amount,
      'method': method,
    });
  }

  /// Returns null on success, error key on failure: 'invalid' | 'already_used'
  static Future<String?> redeemGiftCard(String code) async {
    try {
      await ApiClient.dio.post('/wallet/redeem-gift-card', data: {'code': code});
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  /// Throws 'insufficient' or 'kyc_required' strings on failure
  static Future<String> transfer(double amount, String toUser) async {
    final resp = await ApiClient.dio.post('/wallet/transfer', data: {
      'to_user': toUser,
      'amount': amount,
    });
    return resp.data['transaction_id'].toString();
  }

  static String _extractError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data as Map<String, dynamic>?;
      return data?['error'] as String? ?? 'invalid';
    } catch (_) {
      return 'invalid';
    }
  }

  /// Sync local WalletService state from API (call on wallet screen open)
  static Future<void> sync() async {
    final balance = await getBalance();
    WalletService.balanceNotifier.value = balance;
  }
}

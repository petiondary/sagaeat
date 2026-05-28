import 'package:flutter/foundation.dart';

class KycService {
  KycService._();

  static bool _isVerified = false;
  static final ValueNotifier<bool> verifiedNotifier = ValueNotifier(false);

  // 'free_shipping' | 'discount_6pct' | null
  static String? _kycReward;
  static bool _rewardUsed = false;
  static final ValueNotifier<String?> rewardNotifier = ValueNotifier(null);

  static bool get isVerified => _isVerified;
  static String? get kycReward => _kycReward;
  static bool get hasUnusedReward => _kycReward != null && !_rewardUsed;

  static void markVerified() {
    _isVerified = true;
    verifiedNotifier.value = true;
  }

  static void claimReward(String type) {
    _kycReward = type;
    _rewardUsed = false;
    rewardNotifier.value = type;
  }

  static void useReward() {
    _rewardUsed = true;
    rewardNotifier.value = null;
  }
}

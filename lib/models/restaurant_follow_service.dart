import 'package:flutter/foundation.dart';
import '../data/restaurant_data.dart';

class RestaurantFollowService {
  RestaurantFollowService._();

  static final Set<String> _followed = {};
  static final ValueNotifier<int> countNotifier = ValueNotifier(0);

  static bool isFollowing(String name) => _followed.contains(name);

  static bool toggle(String name) {
    if (_followed.contains(name)) {
      _followed.remove(name);
    } else {
      _followed.add(name);
    }
    countNotifier.value = _followed.length;
    return _followed.contains(name);
  }

  static List<RestaurantInfo> get followedRestaurants =>
      allRestaurantData.where((r) => _followed.contains(r.name)).toList();
}

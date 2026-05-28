enum DeliveryMode { both, pickupOnly, deliveryOnly }

class RestaurantInfo {
  final String name;
  final String emoji;
  final String address;
  final String commune;
  final String departement;
  final String desc;
  final double rating;
  final String deliveryTime;
  final List<String> dishes;
  final DeliveryMode mode;
  final List<String> deliveryZones;
  final double deliveryFee;
  final int tasteCount;

  const RestaurantInfo({
    required this.name,
    required this.emoji,
    required this.address,
    required this.commune,
    required this.departement,
    required this.desc,
    required this.rating,
    required this.deliveryTime,
    required this.dishes,
    required this.mode,
    required this.deliveryZones,
    this.deliveryFee = 150.0,
    this.tasteCount = 0,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> j) => RestaurantInfo(
        name: j['name'] as String,
        emoji: j['emoji'] as String? ?? '🏪',
        address: j['address'] as String,
        commune: j['commune'] as String,
        departement: j['departement'] as String? ?? '',
        desc: j['desc'] as String? ?? '',
        rating: (j['rating'] as num? ?? 0).toDouble(),
        deliveryTime: j['delivery_time'] as String? ?? '30-45 min',
        dishes: (j['dishes'] as List<dynamic>? ?? []).cast<String>(),
        mode: _modeFromString(j['mode'] as String? ?? 'both'),
        deliveryZones: (j['delivery_zones'] as List<dynamic>? ?? []).cast<String>(),
        deliveryFee: (j['delivery_fee'] as num? ?? 150).toDouble(),
        tasteCount: j['taste_count'] as int? ?? 0,
      );

  static DeliveryMode _modeFromString(String s) {
    switch (s) {
      case 'pickup_only':
        return DeliveryMode.pickupOnly;
      case 'delivery_only':
        return DeliveryMode.deliveryOnly;
      default:
        return DeliveryMode.both;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'address': address,
        'commune': commune,
        'departement': departement,
        'desc': desc,
        'rating': rating,
        'delivery_time': deliveryTime,
        'dishes': dishes,
        'mode': mode == DeliveryMode.pickupOnly
            ? 'pickup_only'
            : mode == DeliveryMode.deliveryOnly
                ? 'delivery_only'
                : 'both',
        'delivery_zones': deliveryZones,
        'delivery_fee': deliveryFee,
        'taste_count': tasteCount,
      };

  bool get offersPickup =>
      mode == DeliveryMode.both || mode == DeliveryMode.pickupOnly;

  bool get offersDelivery =>
      mode == DeliveryMode.both || mode == DeliveryMode.deliveryOnly;
}

const List<RestaurantInfo> allRestaurantData = [
  RestaurantInfo(
    name: 'Restoran Mèt Dary',
    emoji: '🏪',
    address: 'Carrefour, Kafou Rit, Monrepos 42',
    commune: 'Carrefour',
    departement: 'Ouest',
    desc:
        'Espesyalite nou se bon manje kreyòl lakay. Bouyon tèt chaje chak samdi, '
        'ak bon kalite sèvis rapid ak sekirite total. Nou kwit avèk amou depi 2010.',
    rating: 4.8,
    deliveryTime: '20-30 min',
    dishes: ['Bouyon', 'Griot', 'Diri Djondjon'],
    mode: DeliveryMode.both,
    deliveryZones: ['Carrefour', 'Gressier', 'Léogâne', 'Arcahaie'],
    deliveryFee: 150.0,
    tasteCount: 2840,
  ),
  RestaurantInfo(
    name: 'Chit Chat Fastfood',
    emoji: '🍔',
    address: 'Carrefour, Diko, Wout nasyonal #2',
    commune: 'Carrefour',
    departement: 'Ouest',
    desc:
        'Pi bon burger, pitza, ak spaghetti nan zòn nan. Vin pase yon bèl moman '
        'oswa kòmande depi lakay ou. Sèvis rapid garanti an 15 minit.',
    rating: 4.5,
    deliveryTime: '15-25 min',
    dishes: ['Burger', 'Spaghetti', 'Pizza'],
    mode: DeliveryMode.both,
    deliveryZones: [
      'Carrefour', 'Delmas', 'Pétion-Ville',
      'Croix-des-Bouquets', 'Port-au-Prince'
    ],
    deliveryFee: 200.0,
    tasteCount: 1530,
  ),
  RestaurantInfo(
    name: 'Lakay Pizza',
    emoji: '🍕',
    address: 'Carrefour, Waney 93, Toupre plas la',
    commune: 'Carrefour',
    departement: 'Ouest',
    desc:
        'Nou kwit pitza nou yo ak bwa pou vrè gou tradisyonèl la. '
        'Pickup sèlman — pase pran pizza ou chak ka!'
        ' Tout engredyan nou yo se pwodwi lokal fre.',
    rating: 4.6,
    deliveryTime: '20-30 min',
    dishes: ['Pizza', 'Calzone', 'Bwason'],
    mode: DeliveryMode.pickupOnly,
    deliveryZones: [],
    deliveryFee: 0.0,
    tasteCount: 980,
  ),
  RestaurantInfo(
    name: 'Bò Lanmè Resto',
    emoji: '🌊',
    address: 'Carrefour, Bò Lanmè, Route 34',
    commune: 'Carrefour',
    departement: 'Ouest',
    desc:
        'Manje fre bò lanmè. Pwason fre, homard, ak krab chak jou. '
        'Vue lanmè pou tout tab. Livrezon sèlman — nou pa gen espas pickup.',
    rating: 4.7,
    deliveryTime: '25-40 min',
    dishes: ['Pwason Fre', 'Homard', 'Krab'],
    mode: DeliveryMode.deliveryOnly,
    deliveryZones: ['Carrefour', 'Gressier'],
    deliveryFee: 250.0,
    tasteCount: 3410,
  ),
];

RestaurantInfo? findRestaurant(String name) {
  try {
    return allRestaurantData.firstWhere((r) => r.name == name);
  } catch (_) {
    return null;
  }
}

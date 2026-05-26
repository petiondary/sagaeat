import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'product_description_screen.dart';
import 'cart_screen.dart';
import 'wallet_screen.dart';
import 'restaurant_detail_screen.dart';
import '../models/cart_service.dart';
import '../models/wallet_service.dart';
import '../models/address_service.dart';
import '../data/haiti_geo.dart';
import '../data/restaurant_data.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kSecondary = Color(0xFFD97706);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);
const Color _kBg = Color(0xFFFAFAF9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAccountVerified = false;

  // ── Categories ─────────────────────────────────────────────────
  int _selectedCategory = 0;
  final List<Map<String, String>> _categories = [
    {"label": "Tout", "emoji": "🍽️"},
    {"label": "Bouyon", "emoji": "🍲"},
    {"label": "Burger", "emoji": "🍔"},
    {"label": "Pizza", "emoji": "🍕"},
    {"label": "Dejeuner", "emoji": "🍱"},
    {"label": "Diner", "emoji": "🌙"},
    {"label": "Souper", "emoji": "🥘"},
    {"label": "Spaghetti", "emoji": "🍝"},
    {"label": "Fritay", "emoji": "🍟"},
    {"label": "Pwason", "emoji": "🐟"},
    {"label": "Bwason", "emoji": "🥤"},
    {"label": "Salad", "emoji": "🥗"},
  ];

  // ── Ad Slideshow ───────────────────────────────────────────────
  int _adIndex = 5000;
  late final PageController _adController;
  late final Timer _adTimer;

  // ── Menu scroll ────────────────────────────────────────────────
  final ScrollController _menuScrollCtrl = ScrollController();

  // ── Profile persistent controllers ────────────────────────────
  final TextEditingController _phoneCtrl =
      TextEditingController(text: '+509 3xxx-xxxx');
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'petiondary@gmail.com');

  // ── Food preferences ──────────────────────────────────────────
  final Set<String> _foodPrefs = {'Bouyon', 'Fritay'};

  // ── Search ────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── History filters ────────────────────────────────────────────
  String _historyStatusFilter = 'all';
  DateTime? _historyStartDate;
  DateTime? _historyEndDate;

  // ── Ad banners (piblisite restoran peye) ──────────────────────
  final List<Map<String, dynamic>> adBanners = [
    {
      "restaurant": "Restoran Mèt Dary",
      "tagline": "Bouyon Spesyal Kreyòl!",
      "promo": "50% Rabè sou premye kòmand ou",
      "image":
          "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80",
      "gradient": [const Color(0xFF78350F), const Color(0xFFB45309)],
      "product": {
        "name": "Bouyon Tèt Chaje",
        "restaurant": "Restoran Mèt Dary",
        "price": 500.0,
        "image":
            "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80",
        "description":
            "Bouyon kreyòl avèk vyann bèf, legim fre, banannn vèt, ak yon gou kay ki pa egziste okote.",
        "category": "Bouyon",
      },
    },
    {
      "restaurant": "Chit Chat Fastfood",
      "tagline": "Pi bon Burger nan Carrefour!",
      "promo": "Achte 2 burger, jwenn 1 gratis",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80",
      "gradient": [const Color(0xFFC2410C), const Color(0xFFEA580C)],
      "product": {
        "name": "Burger Kreyòl Double",
        "restaurant": "Chit Chat Fastfood",
        "price": 350.0,
        "image":
            "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80",
        "description":
            "Double patek avèk bon pikliz, sòs kreyòl maison, leti, tomat fre, ak fwomaj fondan.",
        "category": "Burger",
      },
    },
    {
      "restaurant": "Lakay Pizza",
      "tagline": "Pizza kwit ak bwa reyèl!",
      "promo": "Livrezon gratis sou tout kòmand pizza",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80",
      "gradient": [const Color(0xFF92400E), const Color(0xFFD97706)],
      "product": {
        "name": "Pizza Pòtoprens",
        "restaurant": "Lakay Pizza",
        "price": 750.0,
        "image":
            "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80",
        "description":
            "Fwomaj lokal ak mozarela, janbon, piman dous, zonyon fre, ak sòs tomat maison.",
        "category": "Pizza",
      },
    },
    {
      "restaurant": "Bò Lanmè Resto",
      "tagline": "Fwi Lanmè Fre Chak Jou!",
      "promo": "Gratis yon bwason ak chak kòmand pwason",
      "image":
          "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600&q=80",
      "gradient": [const Color(0xFF065F46), const Color(0xFF059669)],
      "product": {
        "name": "Fritay Pwason Fre",
        "restaurant": "Bò Lanmè Resto",
        "price": 1200.0,
        "image":
            "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400&q=80",
        "description":
            "Pwason wouj fre fri avèk bannann peze, akra, pikliz piman, ak sòs ti-malice.",
        "category": "Pwason",
      },
    },
  ];

  // ── Menu items with real images ────────────────────────────────
  final List<Map<String, dynamic>> allMenuItems = [
    {
      "name": "Bouyon Tèt Chaje",
      "restaurant": "Restoran Mèt Dary",
      "price": 500.0,
      "image":
          "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80",
      "desc":
          "Bouyon kreyòl avèk vyann bèf, legim fre, ak gou kay.",
      "rating": 4.8,
      "category": "Bouyon",
    },
    {
      "name": "Burger Kreyòl Double",
      "restaurant": "Chit Chat Fastfood",
      "price": 350.0,
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80",
      "desc": "Double patek avèk pikliz ak sòs kreyòl maison.",
      "rating": 4.5,
      "category": "Burger",
    },
    {
      "name": "Pizza Pòtoprens",
      "restaurant": "Lakay Pizza",
      "price": 750.0,
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80",
      "desc": "Fwomaj lokal, janbon, piman ak zonyon fre.",
      "rating": 4.3,
      "category": "Pizza",
    },
    {
      "name": "Spaghetti Ayisyen",
      "restaurant": "Chit Chat Fastfood",
      "price": 300.0,
      "image":
          "https://images.unsplash.com/photo-1551183053-bf91798d792e?w=400&q=80",
      "desc": "Spaghetti ak sòs kreyòl, hotdog, ak bon epis lakay.",
      "rating": 4.4,
      "category": "Spaghetti",
    },
    {
      "name": "Poul Griye Dejeuner",
      "restaurant": "Restoran Mèt Dary",
      "price": 650.0,
      "image":
          "https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400&q=80",
      "desc": "Demi poul griye avèk diri kolé ak pikliz maison.",
      "rating": 4.6,
      "category": "Dejeuner",
    },
    {
      "name": "Diri ak Djon-Djon",
      "restaurant": "Restoran Mèt Dary",
      "price": 450.0,
      "image":
          "https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400&q=80",
      "desc": "Diri nwa avèk bon vyann, legim fre, ak sòs kreyòl.",
      "rating": 4.5,
      "category": "Dejeuner",
    },
    {
      "name": "Griot ak Bannann Peze",
      "restaurant": "Bò Lanmè Resto",
      "price": 800.0,
      "image":
          "https://images.unsplash.com/photo-1544025162-d76694265947?w=400&q=80",
      "desc": "Griot fri avèk bannann peze ak pikliz piman maison.",
      "rating": 4.9,
      "category": "Diner",
    },
    {
      "name": "Fritay Pwason Fre",
      "restaurant": "Bò Lanmè Resto",
      "price": 1200.0,
      "image":
          "https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400&q=80",
      "desc": "Pwason fri ak bannann peze, akra, ak pikliz.",
      "rating": 4.7,
      "category": "Pwason",
    },
    {
      "name": "Salade Fre Maison",
      "restaurant": "Chit Chat Fastfood",
      "price": 280.0,
      "image":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80",
      "desc": "Salad fre avèk legim lokal ak vinèg maison.",
      "rating": 4.2,
      "category": "Salad",
    },
    {
      "name": "Smoothie Tropic",
      "restaurant": "Chit Chat Fastfood",
      "price": 200.0,
      "image":
          "https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=400&q=80",
      "desc": "Smoothie mango, papay, ak ananas fre ak lèt kondanse.",
      "rating": 4.6,
      "category": "Bwason",
    },
    {
      "name": "Petit Déjeuner Komplet",
      "restaurant": "Restoran Mèt Dary",
      "price": 350.0,
      "image":
          "https://images.unsplash.com/photo-1494390248081-4e521a5940db?w=400&q=80",
      "desc": "Bread ak bò, ze fri, sòsich, ak yon bon ji sitron.",
      "rating": 4.5,
      "category": "Souper",
    },
    {
      "name": "Souper Kreyòl Complet",
      "restaurant": "Restoran Mèt Dary",
      "price": 600.0,
      "image":
          "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80",
      "desc": "Pla konplè ak vyann, legim, diri, ak yon bwason fre.",
      "rating": 4.7,
      "category": "Souper",
    },
  ];

  // ── Nearby restaurants ─────────────────────────────────────────
  final List<Map<String, dynamic>> nearbyRestaurants = [
    {
      "name": "Restoran Mèt Dary",
      "address": "Carrefour, Kafou Rit, Monrepos 42",
      "desc":
          "Espesyalite nou se bon manje kreyòl lakay, bouyon tèt chaje chak samdi, ak bon kalite sèvis rapid ak sekirite total.",
      "logo": "🏪",
      "rating": "4.8",
      "deliveryTime": "20-30 min",
      "dishes": ["Bouyon", "Griot", "Diri Djondjon"],
    },
    {
      "name": "Chit Chat Fastfood",
      "address": "Carrefour, Diko, Wout nasyonal #2",
      "desc":
          "Pi bon burger, pitza, ak spaghetti nan zòn nan. Vin pase yon bèl moman oswa kòmande depi lakay ou.",
      "logo": "🍔",
      "rating": "4.5",
      "deliveryTime": "15-25 min",
      "dishes": ["Burger", "Spaghetti", "Pizza"],
    },
    {
      "name": "Lakay Pizza",
      "address": "Carrefour, Waney 93, Toupre plas la",
      "desc":
          "Nou kwit pitza nou yo ak bwa pou vrè gou tradisyonèl la. Tout engredyan nou yo se pwodwi lokal fre.",
      "logo": "🍕",
      "rating": "4.6",
      "deliveryTime": "30-45 min",
      "dishes": ["Pizza", "Calzone", "Bwason"],
    },
    {
      "name": "Bò Lanmè Resto",
      "address": "Carrefour, Bò Lanmè, Route 34",
      "desc":
          "Espesyalite nou se pwason fre ak fwi lanmè. Manje nou yo prepare chak jou ak bon kalite ak sèvis chalerez.",
      "logo": "🐟",
      "rating": "4.7",
      "deliveryTime": "25-40 min",
      "dishes": ["Pwason Fri", "Akra", "Bouyon Pwason"],
    },
  ];

  // ── Transaction history ────────────────────────────────────────
  late final List<Map<String, dynamic>> transactionHistory = [
    {
      "order_id": "ORD-2026-8941",
      "item": "Bouyon Spesyal Kreyòl",
      "restaurant": "Restoran Mèt Dary",
      "price": 500.0,
      "date": "Jodi a, 4:04 PM",
      "dateTime": DateTime.now(),
      "status": "En cours",
    },
    {
      "order_id": "ORD-2026-7532",
      "item": "Pizza Pòtoprens",
      "restaurant": "Lakay Pizza",
      "price": 750.0,
      "date": "Ayè, 7:15 PM",
      "dateTime": DateTime.now().subtract(const Duration(days: 1)),
      "status": "En préparation",
    },
    {
      "order_id": "ORD-2026-4122",
      "item": "Burger Kreyòl Double",
      "restaurant": "Chit Chat Fastfood",
      "price": 350.0,
      "date": "18 Me 2026",
      "dateTime": DateTime(2026, 5, 18),
      "status": "Annulé",
    },
    {
      "order_id": "ORD-2026-3011",
      "item": "Fritay Pwason",
      "restaurant": "Bò Lanmè Resto",
      "price": 1200.0,
      "date": "15 Me 2026",
      "dateTime": DateTime(2026, 5, 15),
      "status": "Livré",
    },
  ];

  // ── Filtered menu getter ───────────────────────────────────────
  List<Map<String, dynamic>> get _filteredMenu {
    if (_selectedCategory == 0) return allMenuItems;
    final cat = _categories[_selectedCategory]["label"]!;
    return allMenuItems.where((i) => i["category"] == cat).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _adController = PageController(initialPage: _adIndex);
    _adTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _adIndex++;
      if (_adController.hasClients) {
        _adController.animateToPage(
          _adIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _adTimer.cancel();
    _adController.dispose();
    _menuScrollCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── KYC guard ─────────────────────────────────────────────────
  void _verifyKycAndNavigate(Map<String, dynamic> product) {
    if (!_isAccountVerified) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration:
                BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.gpp_maybe, color: Colors.red.shade700, size: 36),
          ),
          title: const Text("Verifikasyon KYC Obligatwa",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              textAlign: TextAlign.center),
          content: Text(
            "Poutèt rezon sekirite an Ayiti, ou dwe verifye kont ou anvan ou kapab pase yon kòmand. Tanpri ale nan Pwofil ou pou soumèt pyès ou (CIN / NIF / Paspò).",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Anile",
                    style: TextStyle(color: Colors.grey.shade600))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
              child: const Text("Fè KYC Kounye a",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDescriptionScreen(product: product)),
      );
    }
  }

  // ── Body dispatcher ───────────────────────────────────────────
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      case 2:
        return _buildHistoryContent();
      case 3:
        return _buildProfileContent();
      case 4:
        return _buildSettingsContent();
      default:
        return _buildHomeContent();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. HOME
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHomeContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHomeHeader()),
        SliverToBoxAdapter(child: _buildAdSlideshow()),
        SliverToBoxAdapter(child: _buildCategoryRow()),
        SliverToBoxAdapter(child: _buildSectionTitle("Meni ki disponib toupre w")),
        SliverToBoxAdapter(child: _buildMenuCarousel()),
        SliverToBoxAdapter(child: _buildSectionTitle("Restoran ki toupre w")),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) =>
                _buildRestaurantCard(nearbyRestaurants[i % nearbyRestaurants.length]),
            childCount: 10000,
          ),
        ),
      ],
    );
  }

  // ── Gradient home header ──────────────────────────────────────
  Widget _buildHomeHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF78350F), _kPrimary, _kSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 15),
                          const SizedBox(width: 4),
                          const Text("Carrefour, Ayiti",
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 13)),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white70, size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Bonjou, Dary! 👋",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Wallet + Cart badges
                  Row(
                    children: [
                      // Wallet balance chip
                      ValueListenableBuilder<double>(
                        valueListenable: WalletService.balanceNotifier,
                        builder: (context, balance, _) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WalletScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white,
                                      size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${balance.toStringAsFixed(0)} G",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // Cart badge button
                      ValueListenableBuilder<int>(
                        valueListenable: CartService.countNotifier,
                        builder: (context, count, _) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CartScreen()),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 22),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: Text(
                                      "$count",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Chache pla, restoran, zòn...",
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Animated ad slideshow ─────────────────────────────────────
  Widget _buildAdSlideshow() {
    return Column(
      children: [
        const SizedBox(height: 14),
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _adController,
            onPageChanged: (i) => setState(() => _adIndex = i),
            itemCount: 10000,
            itemBuilder: (_, index) {
              final ad = adBanners[index % adBanners.length];
              return _buildAdCard(ad);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(adBanners.length, (i) {
            final active = _adIndex % adBanners.length == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _kPrimary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    final gradients = ad["gradient"] as List<Color>;
    final product = ad["product"] as Map<String, dynamic>;

    return GestureDetector(
      onTap: () => _verifyKycAndNavigate(product),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradients[0].withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -15,
              top: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                    color: Colors.white10, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 90,
              bottom: -25,
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                    color: Colors.white10, shape: BoxShape.circle),
              ),
            ),
            // Food image right side
            Positioned(
              right: 12,
              top: 12,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  ad["image"],
                  width: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            // Text left side
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 155, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("📢 Piblisite",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ad["restaurant"],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 3),
                      Text(
                        ad["tagline"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ad["promo"],
                      style: TextStyle(
                          color: gradients[0],
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category filter row ───────────────────────────────────────
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = i);
              if (_menuScrollCtrl.hasClients) {
                _menuScrollCtrl.animateTo(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _kPrimary : Colors.grey.shade200,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat["emoji"]!, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 5),
                  Text(
                    cat["label"]!,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade700,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _kDark)),
          Text("Wè tout →",
              style: TextStyle(
                  color: _kPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Menu infinite horizontal carousel with real images ────────
  Widget _buildMenuCarousel() {
    final filtered = _filteredMenu;

    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              const Text("😔", style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text("Pa gen pla nan kategori sa a.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 248,
      child: ListView.builder(
        controller: _menuScrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: 10000,
        itemBuilder: (_, index) {
          final item = filtered[index % filtered.length];
          return _buildMenuCard(item);
        },
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    final isUrl = (item["image"] as String).startsWith("http");

    return GestureDetector(
      onTap: () => _verifyKycAndNavigate(item),
      child: Container(
        width: 175,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: isUrl
                  ? Image.network(
                      item["image"],
                      height: 118,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 118,
                        color: _kLight,
                        child: const Center(
                            child:
                                Text("🍽️", style: TextStyle(fontSize: 48))),
                      ),
                    )
                  : Container(
                      height: 118,
                      color: _kLight,
                      child: Center(
                          child: Text(item["image"],
                              style: const TextStyle(fontSize: 48))),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _kDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item["restaurant"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _kPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item["price"]} HTG",
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            "${item["rating"]}",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nearby restaurants infinite vertical list ─────────────────
  Widget _buildRestaurantCard(Map<String, dynamic> resto) {
    final dishes = resto["dishes"] as List<String>;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: _kLight,
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(resto["logo"],
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        resto["name"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _kDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            resto["rating"],
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        resto["address"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.delivery_dining_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(
                      resto["deliveryTime"],
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  resto["desc"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.4),
                ),
                const SizedBox(height: 10),
                // Featured dish pills
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pla: ",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                    Flexible(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: dishes
                            .map((d) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _kLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: _kPrimary,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. SEARCH
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchContent() {
    final q = _searchQuery.toLowerCase().trim();
    final hasQuery = q.isNotEmpty;

    final matchedMenuItems = hasQuery
        ? allMenuItems.where((item) {
            return (item['name'] as String).toLowerCase().contains(q) ||
                (item['restaurant'] as String).toLowerCase().contains(q) ||
                (item['category'] as String).toLowerCase().contains(q);
          }).toList()
        : <Map<String, dynamic>>[];

    final matchedRestaurants = hasQuery
        ? nearbyRestaurants.where((r) {
            return (r['name'] as String).toLowerCase().contains(q) ||
                (r['address'] as String).toLowerCase().contains(q) ||
                (r['dishes'] as List).any(
                    (d) => d.toString().toLowerCase().contains(q));
          }).toList()
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header with search bar ──────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF78350F), _kPrimary, _kSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kisa w ap chache?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: "Pla, bwason, restoran, zòn...",
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() {
                                _searchQuery = '';
                                _searchCtrl.clear();
                              }),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.grey.shade400, size: 18),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Search results ──────────────────────────────────────
        if (hasQuery) ...[
          if (matchedRestaurants.isEmpty && matchedMenuItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("Okenn rezilta pou «$_searchQuery»",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
              ),
            )
          else ...[
            if (matchedRestaurants.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text("Restoran",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _kDark)),
              ),
              ...matchedRestaurants.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: _kLight,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(r['logo'],
                                    style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _kDark)),
                                Text(r['address'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 14),
                              Text(r['rating'].toString(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
            if (matchedMenuItems.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text("Plat",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _kDark)),
              ),
              ...matchedMenuItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item['image'],
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                  width: 52,
                                  height: 52,
                                  color: _kLight,
                                  child: const Center(
                                      child: Text("🍽️",
                                          style: TextStyle(fontSize: 24)))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _kDark)),
                                Text(item['restaurant'],
                                    style: const TextStyle(
                                        color: _kPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Text("${(item['price'] as double).toStringAsFixed(0)} HTG",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ]

        // ── Category chips (when no query) ──────────────────────
        else ...[
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Kategori popilè",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kDark)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories
                  .asMap()
                  .entries
                  .skip(1)
                  .map((e) => _buildSearchChip(
                      e.key, "${e.value["emoji"]} ${e.value["label"]}"))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchChip(int categoryIndex, String label) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = categoryIndex;
        _currentIndex = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. HISTORY
  // ═══════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> get _filteredHistory {
    return transactionHistory.where((tx) {
      // Status filter
      if (_historyStatusFilter != 'all' &&
          tx['status'] != _historyStatusFilter) {
        return false;
      }
      // Date range filter
      final dt = tx['dateTime'] as DateTime;
      if (_historyStartDate != null) {
        final start = DateTime(
            _historyStartDate!.year, _historyStartDate!.month,
            _historyStartDate!.day);
        if (dt.isBefore(start)) return false;
      }
      if (_historyEndDate != null) {
        final end = DateTime(_historyEndDate!.year, _historyEndDate!.month,
            _historyEndDate!.day, 23, 59, 59);
        if (dt.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickHistoryDate(bool isStart) async {
    final initial = isStart
        ? (_historyStartDate ??
            DateTime.now().subtract(const Duration(days: 30)))
        : (_historyEndDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kPrimary)),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (isStart) {
        _historyStartDate = picked;
        if (_historyEndDate != null && _historyEndDate!.isBefore(picked)) {
          _historyEndDate = null;
        }
      } else {
        _historyEndDate = picked;
        if (_historyStartDate != null &&
            _historyStartDate!.isAfter(picked)) {
          _historyStartDate = null;
        }
      }
    });
  }

  Widget _buildHistoryContent() {
    final statusOptions = [
      ('all', 'Tout'),
      ('En cours', 'En cours'),
      ('En préparation', 'Préparasyon'),
      ('Annulé', 'Anile'),
      ('Livré', 'Livre'),
    ];
    final filtered = _filteredHistory;
    final hasDateFilter =
        _historyStartDate != null || _historyEndDate != null;

    return Column(
      children: [
        // ── Header + filters ───────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF78350F), _kPrimary, _kSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Istorik Kòmand yo",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${filtered.length} kòmand",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 14),

                  // Status filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusOptions.map((s) {
                        final selected = _historyStatusFilter == s.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _historyStatusFilter = s.$1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: selected
                                        ? Colors.transparent
                                        : Colors.white38),
                              ),
                              child: Text(
                                s.$2,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? _kPrimary : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date range row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickHistoryDate(true),
                          child: _historyDateBtn(
                            _historyStartDate == null
                                ? 'Dat Debi'
                                : '${_historyStartDate!.day}/${_historyStartDate!.month}/${_historyStartDate!.year}',
                            _historyStartDate != null,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('→',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 16)),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickHistoryDate(false),
                          child: _historyDateBtn(
                            _historyEndDate == null
                                ? 'Dat Fen'
                                : '${_historyEndDate!.day}/${_historyEndDate!.month}/${_historyEndDate!.year}',
                            _historyEndDate != null,
                          ),
                        ),
                      ),
                      if (hasDateFilter) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() {
                            _historyStartDate = null;
                            _historyEndDate = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── List ───────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("Okenn kòmand pou filtre sa",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildOrderCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _historyDateBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: active ? Colors.transparent : Colors.white38),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 12,
              color: active ? _kPrimary : Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? _kPrimary : Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> tx) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (tx["status"]) {
      case "En cours":
        statusColor = Colors.blue.shade700;
        statusBg = Colors.blue.shade50;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case "En préparation":
        statusColor = Colors.orange.shade700;
        statusBg = Colors.orange.shade50;
        statusIcon = Icons.restaurant;
        break;
      case "Annulé":
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        statusIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx["order_id"],
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      letterSpacing: 0.5)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(tx["status"],
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),
          Text(tx["item"],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 17, color: _kDark)),
          const SizedBox(height: 3),
          Text(tx["restaurant"],
              style: const TextStyle(
                  color: _kPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(tx["date"],
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              Text(
                "${tx["price"]} HTG",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. PROFILE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF78350F), _kPrimary, _kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _currentIndex = 4),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.settings_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12)
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 46,
                            backgroundImage: NetworkImage(
                                "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150"),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Chwazi yon nouvo foto pwofil...")),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 15, color: _kPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text("Dary Sebastien Petion",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("petiondary@gmail.com",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isAccountVerified
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _isAccountVerified
                        ? Colors.green.shade200
                        : Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                      _isAccountVerified
                          ? Icons.verified_user
                          : Icons.gpp_bad,
                      color: _isAccountVerified
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _isAccountVerified
                                ? "KYC Apwouve ✓"
                                : "KYC Pa Verifye",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _isAccountVerified
                                    ? Colors.green.shade900
                                    : Colors.red.shade900)),
                        Text(
                            _isAccountVerified
                                ? "Ou kapab pase kòmand lib."
                                : "Soumèt pyès idantite w pou debloke.",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  if (!_isAccountVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade800,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () {
                        setState(() => _isAccountVerified = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Siksè! Dokiman KYC soumèt epi apwouve.")));
                      },
                      child: const Text("Verifye",
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ── Address management ──────────────────────────────────
          _buildAddressesSection(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildProfileField("Non & Prenon", Icons.person_outline,
                    "Dary Sebastien Petion",
                    disabled: true),
                const SizedBox(height: 12),
                _buildProfileField(
                    "Nimewo Telefòn", Icons.phone_outlined, '',
                    keyboardType: TextInputType.phone,
                    controller: _phoneCtrl),
                const SizedBox(height: 12),
                _buildProfileField(
                    "Email", Icons.email_outlined, '',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl),
                const SizedBox(height: 24),
                _buildFoodPrefsSection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Pwofil mete ajou avèk siksè!"))),
                    child: const Text("Anrejistre Chanjman yo",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Address management (profile) ──────────────────────────────
  Widget _buildAddressesSection() {
    return ValueListenableBuilder<int>(
      valueListenable: AddressService.countNotifier,
      builder: (context, _, _) {
        final addrs = AddressService.addresses;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Adres Livrezon yo",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _kDark)),
                  if (AddressService.canAdd)
                    GestureDetector(
                      onTap: () => _showAddressForm(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: _kLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: _kPrimary, size: 15),
                            SizedBox(width: 4),
                            Text("Ajoute",
                                style: TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (addrs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Center(
                      child: Text("Pa gen adres anrejistre.",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13))),
                )
              else
                ...addrs.asMap().entries.map(
                    (e) => _buildAddrCard(e.key, e.value)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddrCard(int index, UserAddress addr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: _kLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on, color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addr.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _kDark)),
                Text("${addr.commune}, ${addr.departement}",
                    style: const TextStyle(
                        color: _kPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                Text(addr.details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => _showAddressForm(editIndex: index),
                child: const Icon(Icons.edit_outlined,
                    color: _kPrimary, size: 18),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  AddressService.remove(index);
                  setState(() {});
                },
                child: Icon(Icons.delete_outline,
                    color: Colors.red.shade400, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressForm({int? editIndex}) {
    final existing =
        editIndex != null ? AddressService.addresses[editIndex] : null;
    String? dept = existing?.departement;
    String? commune = existing?.commune;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final detailsCtrl =
        TextEditingController(text: existing?.details ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(
                    editIndex != null
                        ? "Modifye Adres"
                        : "Nouvo Adres",
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _kDark)),
                const SizedBox(height: 16),
                // Name
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Non Adres (ex: Kay, Travay)",
                    prefixIcon: const Icon(Icons.label_outline, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: _kPrimary, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                // Departement
                DropdownButtonFormField<String>(
                  initialValue: dept,
                  hint: const Text("Chwazi depatman...",
                      style: TextStyle(fontSize: 13)),
                  decoration: InputDecoration(
                    labelText: "Depatman",
                    prefixIcon:
                        const Icon(Icons.map_outlined, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: _kPrimary, width: 2)),
                  ),
                  items: haitiGeo.keys
                      .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d,
                              style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) =>
                      setModal(() {
                        dept = v;
                        commune = null;
                      }),
                ),
                const SizedBox(height: 12),
                // Commune
                DropdownButtonFormField<String>(
                  key: ValueKey('modal_commune_${dept ?? ''}'),
                  initialValue: commune,
                  hint: const Text("Chwazi komin...",
                      style: TextStyle(fontSize: 13)),
                  decoration: InputDecoration(
                    labelText: "Komin",
                    prefixIcon: const Icon(
                        Icons.location_city_outlined,
                        size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: _kPrimary, width: 2)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade100)),
                  ),
                  items: dept != null
                      ? (haitiGeo[dept!] ?? [])
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style:
                                      const TextStyle(fontSize: 13))))
                          .toList()
                      : [],
                  onChanged: dept != null
                      ? (v) => setModal(() => commune = v)
                      : null,
                ),
                const SizedBox(height: 12),
                // Details
                TextField(
                  controller: detailsCtrl,
                  decoration: InputDecoration(
                    labelText: "Detay (Ri, Nimewo Kay...)",
                    prefixIcon:
                        const Icon(Icons.home_outlined, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: _kPrimary, width: 2)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          dept == null ||
                          commune == null ||
                          detailsCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Ranpli tout champs yo.")),
                        );
                        return;
                      }
                      final addr = UserAddress(
                        name: nameCtrl.text.trim(),
                        departement: dept!,
                        commune: commune!,
                        details: detailsCtrl.text.trim(),
                      );
                      if (editIndex != null) {
                        AddressService.update(editIndex, addr);
                      } else {
                        AddressService.add(addr);
                      }
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text("Anrejistre Adres",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodPrefsSection() {
    final prefCategories = _categories.skip(1).map((c) => c["label"]!).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Preferans Manje ou",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: _kDark),
        ),
        const SizedBox(height: 4),
        const Text(
          "Chwazi kategori manje ou renmen plis",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prefCategories.map((cat) {
            final selected = _foodPrefs.contains(cat);
            final emoji =
                _categories.firstWhere((c) => c["label"] == cat)["emoji"]!;
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _foodPrefs.remove(cat);
                } else {
                  _foodPrefs.add(cat);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? _kPrimary.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _kPrimary : Colors.grey.shade300,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? _kDark : Colors.grey.shade600,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_rounded,
                          size: 14, color: _kPrimary),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileField(String label, IconData icon, String value,
      {bool disabled = false,
      TextInputType? keyboardType,
      TextEditingController? controller}) {
    return TextField(
      enabled: !disabled,
      keyboardType: keyboardType,
      controller: controller ?? TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            color: disabled ? Colors.grey.shade400 : _kPrimary, size: 20),
        filled: true,
        fillColor: disabled ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 2)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. SETTINGS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF78350F), _kPrimary, _kSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text("Paramètres",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _buildSettingsGroup("Preferans Aplikasyon", [
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              iconBg: Colors.blue.shade50,
              iconColor: Colors.blue.shade600,
              title: "Notifikasyon Kòmand",
              subtitle: "Resevwa alèt lè eta kòmand ou chanje",
              trailing: Switch(
                  value: true,
                  activeThumbColor: _kPrimary,
                  onChanged: (_) {}),
            ),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              iconBg: Colors.purple.shade50,
              iconColor: Colors.purple.shade600,
              title: "Lang Aplikasyon an",
              subtitle: "Kreyòl Ayisyen",
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              iconBg: Colors.grey.shade100,
              iconColor: Colors.grey.shade700,
              title: "Mòd Koulè",
              subtitle: "Klè (Light mode)",
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSettingsGroup("Kont & Sekirite", [
            _buildSettingsTile(
              icon: Icons.lock_outline,
              iconBg: _kLight,
              iconColor: _kPrimary,
              title: "Sekirite",
              subtitle: "Chanje modpas, 2FA...",
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            _buildSettingsTile(
              icon: Icons.help_outline,
              iconBg: Colors.green.shade50,
              iconColor: Colors.green.shade700,
              title: "Èd & Sipò",
              subtitle: "Kontakte nou si ou gen pwoblèm",
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            _buildSettingsTile(
              icon: Icons.exit_to_app,
              iconBg: Colors.red.shade50,
              iconColor: Colors.red.shade700,
              title: "Dekonekte",
              titleColor: Colors.red.shade700,
              trailing: const SizedBox.shrink(),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: tiles
                  .asMap()
                  .entries
                  .map((e) => Column(
                        children: [
                          e.value,
                          if (e.key < tiles.length - 1)
                            Divider(
                                indent: 56,
                                endIndent: 16,
                                height: 1,
                                color: Colors.grey.shade100),
                        ],
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 38,
        height: 38,
        decoration:
            BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: titleColor ?? _kDark)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
          : null,
      trailing: trailing,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SCAFFOLD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: _kPrimary,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 11),
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search_rounded),
                  label: "Rechèch"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: "Istorik"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: "Pwofil"),
            ],
          ),
        ),
      ),
    );
  }
}

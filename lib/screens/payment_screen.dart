import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cart_service.dart';
import '../models/wallet_service.dart';
import '../models/address_service.dart';
import '../models/order_service.dart';
import '../data/haiti_geo.dart';
import '../data/restaurant_data.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);

const double _deliveryFeePerRestaurant = 150.0;

class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double couponDiscount;
  final String? couponCode;

  const PaymentScreen({
    super.key,
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    this.couponDiscount = 0.0,
    this.couponCode,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _addrIndex = 0;

  String? _newDept;
  String? _newCommune;
  final _newDetailsCtrl = TextEditingController();

  // Phone fields
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  bool _phone1WhatsApp = false;
  bool _phone2WhatsApp = false;

  late final Map<String, String> _orderIds;

  // Restaurants the user picked up (includes pickupOnly restaurants auto-added)
  final Set<String> _pickupRestaurants = {};

  @override
  void initState() {
    super.initState();
    _addrIndex = AddressService.addresses.isNotEmpty ? 0 : -1;

    _orderIds = {};
    int counter = 0;
    final seed = DateTime.now().millisecondsSinceEpoch;
    final pickupOnlyNames = <String>[];
    for (final item in CartService.items) {
      final r = item['restaurant'] as String;
      if (!_orderIds.containsKey(r)) {
        final p1 = ((seed + counter * 1777) % 10000).toString().padLeft(4, '0');
        final p2 = ((seed + counter * 3333 + 9999) % 10000).toString().padLeft(4, '0');
        final p3 = ((seed + counter * 57 + 11) % 100).toString().padLeft(2, '0');
        _orderIds[r] = 'sagaeat-$p1-$p2-$p3';
        counter++;
        final info = findRestaurant(r);
        if (info != null && info.mode == DeliveryMode.pickupOnly) {
          _pickupRestaurants.add(r);
          pickupOnlyNames.add(r);
        }
      }
    }
    if (pickupOnlyNames.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPickupOnlyInfo(pickupOnlyNames);
      });
    }
  }

  void _showPickupOnlyInfo(List<String> names) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.directions_walk_rounded,
              color: _kPrimary, size: 32),
        ),
        title: const Text("Pickup sèlman",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${names.join(' ak ')} ${names.length == 1 ? 'pa fè' : 'pa fè'} livrezon.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ou oblije pase nan restoran an pou pran manje ou.\nEske w dakò ak sa?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // retounen nan panye
            },
            child: const Text("Non, retounen",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Wi, dakò",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newDetailsCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> get _byRestaurant {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final item in CartService.items) {
      map.putIfAbsent(item['restaurant'] as String, () => []).add(item);
    }
    return map;
  }

  double get _adjustedDeliveryFee {
    double total = 0;
    for (final r in _byRestaurant.keys) {
      if (_pickupRestaurants.contains(r)) continue;
      final info = findRestaurant(r);
      total += info?.deliveryFee ?? _deliveryFeePerRestaurant;
    }
    return total;
  }

  double get _serviceFee =>
      (widget.subtotal + _adjustedDeliveryFee) * 0.06;

  double get _total =>
      widget.subtotal +
      _serviceFee +
      _adjustedDeliveryFee -
      widget.couponDiscount;

  String? get _commune {
    if (_addrIndex >= 0 && _addrIndex < AddressService.addresses.length) {
      return AddressService.addresses[_addrIndex].commune;
    }
    return _newCommune;
  }

  bool get _allPickup =>
      _byRestaurant.keys.isNotEmpty &&
      _byRestaurant.keys.every((r) => _pickupRestaurants.contains(r));

  bool get _addressValid {
    if (_allPickup) return true;
    if (_addrIndex >= 0) return true;
    return _newDept != null &&
        _newCommune != null &&
        _newDetailsCtrl.text.trim().isNotEmpty;
  }

  bool _delivers(String restaurant, String? commune) {
    if (commune == null) return true;
    final info = findRestaurant(restaurant);
    if (info == null) return true;
    if (!info.offersDelivery) return false;
    return info.deliveryZones.contains(commune);
  }

  bool get _hasDeliveryWarning =>
      _commune != null &&
      _byRestaurant.keys.any(
          (r) => !_pickupRestaurants.contains(r) && !_delivers(r, _commune));

  List<String> get _nonDeliveringRestaurants {
    final commune = _commune;
    if (commune == null) return [];
    return _byRestaurant.keys
        .where(
            (r) => !_pickupRestaurants.contains(r) && !_delivers(r, commune))
        .toList();
  }

  void _removeNonDelivering() {
    final bad = Set<String>.from(_nonDeliveringRestaurants);
    final items = CartService.items;
    final toRemove = <int>[];
    for (int i = 0; i < items.length; i++) {
      if (bad.contains(items[i]['restaurant'] as String)) toRemove.add(i);
    }
    for (final i in toRemove.reversed) {
      CartService.updateQuantity(i, 0);
    }
    setState(() {});
  }

  void _confirmPickupSelection(String restaurantName) {
    final info = findRestaurant(restaurantName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _kLight, shape: BoxShape.circle),
          child: const Icon(Icons.directions_walk_rounded,
              color: _kPrimary, size: 32),
        ),
        title: const Text("Pran sou plas?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ou chwazi pran manje a sou plas nan «$restaurantName».",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              "Restoran an pa ap livre manje a — se ou menm ki pral pase pran li.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.4),
            ),
            if (info != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _kLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: _kPrimary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${info.address}\n${info.commune}, ${info.departement}",
                        style: const TextStyle(
                            fontSize: 11,
                            color: _kDark,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Anile",
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _pickupRestaurants.add(restaurantName));
              _checkPickupCommune(restaurantName);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Wi, pran sou plas",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Show popup when restaurant commune ≠ user commune (pickup)
  void _checkPickupCommune(String restaurantName) {
    final info = findRestaurant(restaurantName);
    if (info == null) return;
    final userCommune = _commune;
    if (userCommune == null) return;
    if (info.commune == userCommune) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.location_off_rounded,
            color: Colors.orange, size: 36),
        title: const Text("Restoran pa nan menm komin",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Restoran «$restaurantName» pa nan komin ou a.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoChip(Icons.storefront_outlined,
                      "$restaurantName: ${info.commune}, ${info.departement}"),
                  const SizedBox(height: 6),
                  _infoChip(Icons.person_pin_circle_outlined,
                      "Ou: $userCommune"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Eske w ap toujou fè acha sa a?",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _pickupRestaurants.remove(restaurantName));
              Navigator.pop(ctx);
            },
            child: const Text("Non, anile pickup",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Wi, kontinye",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kPrimary),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: _kDark))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _byRestaurant;
    final addresses = AddressService.addresses;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF78350F), _kPrimary, Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text("Paj Pèman",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Kòmand yo"),
                  const SizedBox(height: 10),
                  ...orders.entries
                      .map((e) => _buildOrderGroup(e.key, e.value)),

                  _buildCostSummary(),
                  const SizedBox(height: 24),

                  if (!_allPickup) ...[
                    _sectionTitle("Adres Livrezon"),
                    const SizedBox(height: 10),
                    _buildAddressSection(addresses),
                    const SizedBox(height: 16),
                    if (_hasDeliveryWarning) _buildWarning(),
                  ],

                  // Phone numbers
                  _sectionTitle("Nimewo Telefòn"),
                  const SizedBox(height: 8),
                  _buildPhoneSection(),
                  const SizedBox(height: 24),

                  _sectionTitle("Mwayen Pèman"),
                  const SizedBox(height: 10),
                  _buildWalletTile(),
                  const SizedBox(height: 10),
                  _payBtn("Tranzak (Kaypa)", const Color(0xFF1D4ED8),
                      Icons.account_balance_wallet_outlined),
                  const SizedBox(height: 10),
                  _payBtn("MonCash", const Color(0xFFDC2626),
                      Icons.phone_android_outlined),
                  const SizedBox(height: 10),
                  _payBtn("Natcash", const Color(0xFF1E3A8A),
                      Icons.phone_android_outlined),
                  const SizedBox(height: 10),
                  _payBtn("Carte Bancaire (Taux 135)",
                      const Color(0xFF16A34A), Icons.credit_card_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: _kDark));

  // ── Order group ─────────────────────────────────────────────────
  Widget _buildOrderGroup(
      String restaurant, List<Map<String, dynamic>> items) {
    final baseId = _orderIds[restaurant] ?? 'sagaeat-????-????-??';
    final isPickupForId = _pickupRestaurants.contains(restaurant);
    final orderId = '$baseId-${isPickupForId ? 'P' : 'D'}';
    final commune = _commune;
    final info = findRestaurant(restaurant);
    final isPickupOnly = info?.mode == DeliveryMode.pickupOnly;
    final isDeliveryOnly = info?.mode == DeliveryMode.deliveryOnly;
    final isPickup = _pickupRestaurants.contains(restaurant);
    final ok = _delivers(restaurant, commune);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: _kLight,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        color: _kPrimary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _kDark)),
                          Text(orderId,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    // Mode badge
                    if (isPickupOnly)
                      _modeBadge("Pickup sèlman", _kPrimary,
                          Icons.directions_walk_rounded)
                    else if (isDeliveryOnly)
                      _modeBadge("Livrezon sèlman", Colors.blue.shade700,
                          Icons.delivery_dining_rounded)
                    else if (commune != null && !isPickup)
                      _deliveryBadge(ok),
                    if (isPickup && !isPickupOnly)
                      _modeBadge("Pickup", _kPrimary,
                          Icons.directions_walk_rounded),
                  ],
                ),

                // Restaurant address shown when pickup
                if ((isPickup || isPickupOnly) && info != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: _kPrimary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info.address,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _kDark)),
                              Text("${info.commune}, ${info.departement}",
                                  style: const TextStyle(
                                      fontSize: 10, color: _kPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Pickup toggle (only for 'both' mode restaurants)
                if (!isPickupOnly && !isDeliveryOnly) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (isPickup) {
                        setState(() =>
                            _pickupRestaurants.remove(restaurant));
                      } else {
                        _confirmPickupSelection(restaurant);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isPickup
                            ? _kPrimary.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPickup
                              ? _kPrimary.withValues(alpha: 0.4)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPickup
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: isPickup
                                ? _kPrimary
                                : Colors.grey.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pran sou plas (Pickup)",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isPickup
                                        ? _kDark
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  isPickup
                                      ? "Frè livrezon anile pou restoran sa a"
                                      : "Chwazi pou pase pran manje a",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isPickup
                                          ? _kPrimary
                                          : Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                          if (isPickup)
                            const Text("−150 HTG",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669))),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _modeBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _deliveryBadge(bool ok) {
    final color = ok ? Colors.green.shade700 : Colors.orange.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ok ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              ok
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              size: 11,
              color: color),
          const SizedBox(width: 3),
          Text(ok ? "Livre nan zòn ou" : "Pa livre la",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final isUrl = (item['image'] as String).startsWith('http');
    final qty = item['quantity'] as int;
    final unitPrice = item['unitPrice'] as double;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isUrl
                ? Image.network(item['image'],
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _emojiBox("🍽️"))
                : _emojiBox(item['image'] as String),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kDark)),
                const SizedBox(height: 2),
                Text("x$qty  ×  ${unitPrice.toStringAsFixed(0)} HTG",
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                if ((item['supplements'] as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: (item['supplements'] as List)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: _kLight,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text('+ ${s['name']}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: _kPrimary,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Text(
            "${((unitPrice + (item['suppTotal'] as double? ?? 0.0)) * qty).toStringAsFixed(0)} HTG",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.green.shade700)),
        ],
      ),
    );
  }

  Widget _emojiBox(String emoji) => Container(
      width: 52,
      height: 52,
      color: _kLight,
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))));

  // ── Cost summary ────────────────────────────────────────────────
  Widget _buildCostSummary() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          _row("Soutotal", "${widget.subtotal.toStringAsFixed(0)} HTG"),
          const SizedBox(height: 6),
          _row("Frè Sèvis", "${_serviceFee.toStringAsFixed(0)} HTG",
              color: Colors.grey.shade600),
          ..._byRestaurant.keys.map((r) {
            final isPickup = _pickupRestaurants.contains(r);
            final info = findRestaurant(r);
            final fee = isPickup ? 0.0 : (info?.deliveryFee ?? _deliveryFeePerRestaurant);
            return Column(
              children: [
                const SizedBox(height: 6),
                _row(
                  'Livrezon · $r',
                  isPickup ? 'Pickup' : '${fee.toStringAsFixed(0)} HTG',
                  color: isPickup ? _kPrimary : Colors.grey.shade600,
                ),
              ],
            );
          }),
          if (widget.couponDiscount > 0) ...[
            const SizedBox(height: 6),
            _row("Koupon (${widget.couponCode ?? ''})",
                "-${widget.couponDiscount.toStringAsFixed(0)} HTG",
                color: Colors.green.shade700),
          ],
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1)),
          _row("Total", "${_total.toStringAsFixed(0)} HTG",
              bold: true, color: _kPrimary),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) {
    final s = TextStyle(
        fontSize: bold ? 16 : 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: color ?? _kDark);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: s), Text(value, style: s)]);
  }

  // ── Address section ─────────────────────────────────────────────
  Widget _buildAddressSection(List<UserAddress> addresses) {
    return Column(
      children: [
        ...addresses.asMap().entries.map((e) => _addrTile(e.key, e.value)),
        GestureDetector(
          onTap: () => setState(() => _addrIndex = -1),
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _addrIndex == -1 ? _kLight : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    _addrIndex == -1 ? _kPrimary : Colors.grey.shade200,
                width: _addrIndex == -1 ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              _radioCircle(_addrIndex == -1),
              const SizedBox(width: 12),
              const Icon(Icons.add_location_alt_outlined,
                  color: _kPrimary, size: 18),
              const SizedBox(width: 8),
              const Text("Antre yon nouvo adres",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kDark)),
            ]),
          ),
        ),
        if (_addrIndex == -1) ...[
          const SizedBox(height: 10),
          _buildNewAddrForm(),
        ],
      ],
    );
  }

  Widget _addrTile(int index, UserAddress addr) {
    final selected = _addrIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _addrIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _kPrimary : Colors.grey.shade200,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            _radioCircle(selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addr.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
          ],
        ),
      ),
    );
  }

  Widget _radioCircle(bool selected) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? _kPrimary : Colors.grey.shade400,
              width: 2),
          color: selected ? _kPrimary : Colors.transparent,
        ),
        child: selected
            ? const Icon(Icons.check, size: 12, color: Colors.white)
            : null,
      );

  Widget _buildNewAddrForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _newDept,
            hint: const Text("Chwazi depatman...",
                style: TextStyle(fontSize: 13)),
            decoration: _dropDeco("Depatman", Icons.map_outlined),
            items: haitiGeo.keys
                .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() {
              _newDept = v;
              _newCommune = null;
            }),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('commune_${_newDept ?? ''}'),
            initialValue: _newCommune,
            hint: const Text("Chwazi komin...",
                style: TextStyle(fontSize: 13)),
            decoration: _dropDeco("Komin", Icons.location_city_outlined),
            items: _newDept != null
                ? (haitiGeo[_newDept!] ?? [])
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(fontSize: 13))))
                    .toList()
                : [],
            onChanged:
                _newDept != null ? (v) => setState(() => _newCommune = v) : null,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newDetailsCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: "Detay (Ri, Nimewo Kay...)",
              prefixIcon:
                  const Icon(Icons.home_outlined, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: _kPrimary, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade100)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: _kPrimary, width: 2)),
      );

  // ── Phone section (2 phones + WhatsApp) ─────────────────────────
  Widget _buildPhoneSection() {
    return Column(
      children: [
        _phoneField(
          ctrl: _phone1Ctrl,
          label: "Nimewo 1",
          hint: "+509 xxxx-xxxx",
          hasWhatsApp: _phone1WhatsApp,
          onWhatsAppToggle: (v) => setState(() => _phone1WhatsApp = v),
        ),
        const SizedBox(height: 10),
        _phoneField(
          ctrl: _phone2Ctrl,
          label: "Nimewo 2 (Opsyonèl)",
          hint: "+509 xxxx-xxxx",
          hasWhatsApp: _phone2WhatsApp,
          onWhatsAppToggle: (v) => setState(() => _phone2WhatsApp = v),
        ),
        const SizedBox(height: 4),
        Text(
          "Livreur a ka kontakte w dirèkteman si nesesè",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _phoneField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool hasWhatsApp,
    required ValueChanged<bool> onWhatsAppToggle,
  }) {
    return Column(
      children: [
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-]'))
          ],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: const Icon(Icons.phone_outlined,
                color: _kPrimary, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: _kPrimary, width: 2)),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => onWhatsAppToggle(!hasWhatsApp),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: hasWhatsApp
                      ? const Color(0xFF25D366)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: hasWhatsApp
                        ? const Color(0xFF25D366)
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: hasWhatsApp
                    ? const Icon(Icons.check,
                        size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chat_rounded,
                  color: Color(0xFF25D366), size: 16),
              const SizedBox(width: 4),
              Text(
                "Nimewo sa gen WhatsApp",
                style: TextStyle(
                    fontSize: 12,
                    color: hasWhatsApp
                        ? const Color(0xFF25D366)
                        : Colors.grey.shade600,
                    fontWeight: hasWhatsApp
                        ? FontWeight.w600
                        : FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Warning with action buttons ──────────────────────────────────
  Widget _buildWarning() {
    final bad = _nonDeliveringRestaurants;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${bad.length} restoran pa livre nan komin ou a:\n"
                  "${bad.join(', ')}",
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      title: const Text("Siprime kòmand yo?",
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                      content: Text(
                        "W ap retire kòmand ${bad.join(' ak ')} nan panye ou.",
                        style: const TextStyle(
                            fontSize: 13, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Anile",
                              style:
                                  TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _removeNonDelivering();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                          child: const Text("Retire",
                              style:
                                  TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  icon: Icon(Icons.delete_outline,
                      size: 15, color: Colors.red.shade600),
                  label: Text("Retire yo",
                      style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addressValid
                      ? () {
                          _removeNonDelivering();
                          Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _confirm("Pèman rapid", _kPrimary));
                        }
                      : null,
                  icon: const Icon(Icons.check_circle_outline,
                      size: 15, color: Colors.white),
                  label: const Text("Plase ki livre yo",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    disabledBackgroundColor:
                        Colors.green.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Wallet tile ─────────────────────────────────────────────────
  Widget _buildWalletTile() {
    return ValueListenableBuilder<double>(
      valueListenable: WalletService.balanceNotifier,
      builder: (context, balance, _) {
        final ok = balance >= _total;
        return GestureDetector(
          onTap: ok && _addressValid ? _showWalletConfirm : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ok ? const Color(0xFFF5F3FF) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: ok
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.35)
                      : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ok
                        ? const Color(0xFF7C3AED)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color:
                          ok ? Colors.white : Colors.grey.shade500,
                      size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Wallet SagaEat",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _kDark)),
                      Text(
                        "Balans: ${balance.toStringAsFixed(0)} HTG",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ok
                                ? const Color(0xFF7C3AED)
                                : Colors.grey.shade500),
                      ),
                      if (!ok)
                        Text(
                          "Fon ensifizèn — manke "
                          "${(_total - balance).toStringAsFixed(0)} HTG",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade400),
                        ),
                    ],
                  ),
                ),
                if (ok && _addressValid)
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Color(0xFF7C3AED)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWalletConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Color(0xFF7C3AED), size: 36),
        ),
        title: const Text("Peye via Wallet?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center),
        content: Text(
          "W ap deduwe ${_total.toStringAsFixed(0)} HTG nan Wallet SagaEat ou.\n"
          "Eske ou konfime?",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey.shade600, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("Anile", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirm("Wallet SagaEat", const Color(0xFF7C3AED),
                  useWallet: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Wi, Peye",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _payBtn(String label, Color color, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        onPressed: _addressValid ? () => _confirm(label, color) : null,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
    );
  }

  void _confirm(String method, Color color, {bool useWallet = false}) {
    if (!_addressValid) return;
    final commune = _commune ?? '';
    final pickupList = _pickupRestaurants.toList();
    final String deliveryInfo;
    if (_allPickup) {
      deliveryInfo = "Pickup — Pase pran manje ou nan restoran an.\nLè kòmand lan prè, n ap enfòme w.";
    } else if (pickupList.isEmpty) {
      deliveryInfo = "Livrezon → $commune\nLè kòmand lan prè n ap enfòme w.";
    } else {
      deliveryInfo = "Livrezon → $commune\nPickup: ${pickupList.join(', ')}\nLè kòmand lan prè n ap enfòme w.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(Icons.check_circle_outline_rounded,
              color: color, size: 40),
        ),
        title: const Text("Kòmand Konfime!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center),
        content: Text(
          "Pèman via $method.\n$deliveryInfo\n"
          "Nou pral prepare kòmand ou trè vit!",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey.shade600, fontSize: 13, height: 1.4),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (useWallet) WalletService.deduct(_total);
                final byResto = _byRestaurant;
                final now = DateTime.now();
                byResto.forEach((restaurant, items) {
                  final baseId = _orderIds[restaurant] ?? 'sagaeat-0000-0000-00';
                  final isPickup = _pickupRestaurants.contains(restaurant);
                  final orderId = '$baseId-${isPickup ? 'P' : 'D'}';
                  final restoDeliveryFee =
                      isPickup ? 0.0 : _deliveryFeePerRestaurant;
                  final restoSubtotal = items.fold<double>(
                      0, (s, i) => s + (i['unitPrice'] as double) * (i['quantity'] as int));
                  final restoServiceFee =
                      (restoSubtotal + restoDeliveryFee) * 0.06;
                  OrderService.add(OrderRecord(
                    orderId: orderId,
                    restaurant: restaurant,
                    items: List<Map<String, dynamic>>.from(items),
                    subtotal: restoSubtotal,
                    serviceFee: restoServiceFee,
                    deliveryFee: restoDeliveryFee,
                    couponDiscount: 0,
                    total: restoSubtotal + restoServiceFee + restoDeliveryFee,
                    mode: isPickup ? 'pickup' : 'delivery',
                    createdAt: now,
                  ));
                });
                CartService.clear();
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: const Text("OK, Mèsi!",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

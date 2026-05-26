import 'package:flutter/material.dart';
import '../models/cart_service.dart';
import 'payment_screen.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const double _deliveryFee = 150.0;
  static const double _serviceFeeRate = 0.06;

  // Coupon
  final _couponCtrl = TextEditingController();
  double _couponDiscount = 0.0;
  bool _couponApplied = false;
  bool _invalidCoupon = false;
  String _appliedCode = '';

  // demo coupons: code → {type: 'pct'|'fixed', value}
  static const Map<String, Map<String, dynamic>> _validCoupons = {
    'SAGA10': {'type': 'pct', 'value': 0.10, 'label': '-10%'},
    'BIENVENI': {'type': 'pct', 'value': 0.15, 'label': '-15%'},
    'VIP500': {'type': 'fixed', 'value': 500.0, 'label': '-500 HTG'},
  };

  void _applyCoupon(double subtotal) {
    final code = _couponCtrl.text.trim().toUpperCase();
    final coupon = _validCoupons[code];
    if (coupon != null) {
      final double discount = coupon['type'] == 'pct'
          ? subtotal * (coupon['value'] as double)
          : (coupon['value'] as double).clamp(0, subtotal);
      setState(() {
        _couponDiscount = discount;
        _couponApplied = true;
        _invalidCoupon = false;
        _appliedCode = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Koupon $code apllike! ${coupon['label']}"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } else {
      setState(() {
        _couponDiscount = 0.0;
        _couponApplied = false;
        _invalidCoupon = true;
        _appliedCode = '';
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _couponDiscount = 0.0;
      _invalidCoupon = false;
      _appliedCode = '';
      _couponCtrl.clear();
    });
  }

  void _updateQty(int index, int qty) {
    CartService.updateQuantity(index, qty);
    // recalculate pct coupon if active
    if (_couponApplied) {
      final coupon = _validCoupons[_appliedCode];
      if (coupon != null && coupon['type'] == 'pct') {
        _couponDiscount = CartService.grandTotal * (coupon['value'] as double);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = CartService.items;
    final subtotal = CartService.grandTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text("Panyen mwen",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    if (items.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          CartService.clear();
                          _removeCoupon();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text("Efase tout",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          if (items.isEmpty)
            Expanded(child: _buildEmptyState())
          else ...[
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                itemCount: items.length,
                itemBuilder: (_, i) => _buildCartItem(i, items[i]),
              ),
            ),
            _buildOrderSummary(subtotal),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration:
                const BoxDecoration(color: _kLight, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 56, color: _kPrimary),
          ),
          const SizedBox(height: 20),
          const Text("Panyen ou vid!",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _kDark)),
          const SizedBox(height: 8),
          Text("Ajoute pla ou renmen yo pou kòmanse.",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            label: const Text("Retounen nan meni an",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, Map<String, dynamic> item) {
    final isUrl = (item['image'] as String).startsWith('http');
    final qty = item['quantity'] as int;
    final unitPrice = item['unitPrice'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isUrl
                ? Image.network(item['image'],
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _emojiBox())
                : _emojiBox(emoji: item['image'] as String),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _kDark)),
                const SizedBox(height: 3),
                Text(item['restaurant'],
                    style: const TextStyle(
                        color: _kPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${(unitPrice * qty).toStringAsFixed(0)} HTG",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green.shade700)),
                    Row(children: [
                      _qtyBtn(
                          icon: Icons.remove,
                          onTap: () => _updateQty(index, qty - 1),
                          active: qty > 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("$qty",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      _qtyBtn(
                          icon: Icons.add,
                          onTap: () => _updateQty(index, qty + 1),
                          active: true),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _updateQty(index, 0),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.delete_outline,
                  color: Colors.red.shade400, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiBox({String emoji = "🍽️"}) => Container(
      width: 72,
      height: 72,
      color: _kLight,
      child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 36))));

  Widget _qtyBtn(
      {required IconData icon,
      required VoidCallback onTap,
      required bool active}) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: active ? _kLight : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon,
            size: 16,
            color: active ? _kPrimary : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    final serviceFee = subtotal * _serviceFeeRate;
    final total =
        (subtotal + serviceFee + _deliveryFee - _couponDiscount)
            .clamp(0.0, double.infinity);

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Coupon field ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_couponApplied,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Kode koupon  (ex: SAGA10)",
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12),
                    errorText:
                        _invalidCoupon ? "Kode a pa valid" : null,
                    prefixIcon: Icon(Icons.local_offer_outlined,
                        size: 18,
                        color: _couponApplied
                            ? Colors.green.shade600
                            : _kPrimary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor:
                        _couponApplied ? Colors.green.shade50 : Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.green.shade300)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _kPrimary, width: 2)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.red.shade400)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.red.shade400, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _couponApplied
                  ? GestureDetector(
                      onTap: _removeCoupon,
                      child: Container(
                        height: 48,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Icon(Icons.check,
                                color: Colors.white, size: 20)),
                      ),
                    )
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          elevation: 0,
                        ),
                        onPressed: () => _applyCoupon(subtotal),
                        child: const Text("Apllike",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Summary rows ──────────────────────────────────────
          const Text("Rezime Kòmand",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _kDark)),
          const SizedBox(height: 12),
          _row("Soutotal", "${subtotal.toStringAsFixed(0)} HTG"),
          const SizedBox(height: 6),
          _row("Frè Sèvis",
              "${serviceFee.toStringAsFixed(0)} HTG",
              color: Colors.grey.shade600),
          const SizedBox(height: 6),
          _row("Frè Livrezon",
              "${_deliveryFee.toStringAsFixed(0)} HTG",
              color: Colors.grey.shade600),
          if (_couponApplied) ...[
            const SizedBox(height: 6),
            _row("Koupon ($_appliedCode)",
                "-${_couponDiscount.toStringAsFixed(0)} HTG",
                color: Colors.green.shade700),
          ],
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1)),
          _row("Total", "${total.toStringAsFixed(0)} HTG",
              bold: true, color: _kPrimary),
          const SizedBox(height: 16),

          // ── Checkout button ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    subtotal: subtotal,
                    serviceFee: serviceFee,
                    deliveryFee: _deliveryFee,
                    couponDiscount: _couponDiscount,
                    couponCode:
                        _couponApplied ? _appliedCode : null,
                  ),
                ),
              ),
              child: const Text("Pase Kòmand",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
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
}

import 'package:flutter/material.dart';
import '../data/restaurant_data.dart';
import 'product_description_screen.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantInfo restaurant;
  final List<Map<String, dynamic>> menuItems;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.menuItems,
  });

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  int _reviewRating = 0;
  final _reviewCtrl = TextEditingController();

  // Demo reviews
  final List<_Review> _reviews = [
    _Review('J**n B****e', 5, 'Manje a te excellent! Bouyon te cho ak bon gou.', '2 jou de sa'),
    _Review('M***e C****e', 4, 'Sèvis rapid, manje bon. Mwen rekòmande!', '5 jou de sa'),
    _Review('P***k D****y', 3, 'Manje te bon men livrezon te pran tan.', '1 semèn de sa'),
  ];

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_reviewRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Bay yon pwen anvan ou soumèt."),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_reviewCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Kòmantè a obligatwa."),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() {
      _reviews.insert(
        0,
        _Review('Ou', _reviewRating, _reviewCtrl.text.trim(), 'Kounye a'),
      );
      _reviewRating = 0;
      _reviewCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("✓ Kòmantè ou poste!"),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _kPrimary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF78350F), _kPrimary, Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(r.emoji,
                          style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Text(r.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(r.rating.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(r.deliveryTime,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(r.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),

          // ── Info section ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery mode badge
                  _buildModeBadge(r),
                  const SizedBox(height: 14),

                  // Address
                  _infoRow(Icons.location_on_outlined, r.address, _kPrimary),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_city_outlined,
                      '${r.commune}, ${r.departement}', Colors.grey.shade600),
                  const SizedBox(height: 14),

                  // Description
                  Text(r.desc,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.5)),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          // ── Menu items ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: const Text("Meni",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kDark)),
            ),
          ),
          if (widget.menuItems.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: Text("Okenn pla disponib pou kounye a.",
                        style: TextStyle(color: Colors.grey))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildMenuItem(widget.menuItems[i]),
                  childCount: widget.menuItems.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),

          // ── Reviews ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Kòmantè",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _kDark)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: _kLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("${_reviews.length}",
                            style: const TextStyle(
                                color: _kPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Leave review
                  _buildReviewInput(),
                  const SizedBox(height: 16),

                  // Review list
                  ..._reviews.map((rev) => _buildReviewCard(rev)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadge(RestaurantInfo r) {
    final (label, icon, color) = switch (r.mode) {
      DeliveryMode.both => ('Livrezon + Pickup', Icons.swap_horiz_rounded, Colors.green.shade700),
      DeliveryMode.pickupOnly => ('Pickup sèlman', Icons.directions_walk_rounded, _kPrimary),
      DeliveryMode.deliveryOnly => ('Livrezon sèlman', Icons.delivery_dining_rounded, Colors.blue.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(color: color, fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final isUrl = (item['image'] as String).startsWith('http');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDescriptionScreen(product: item),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: isUrl
                  ? Image.network(
                      item['image'],
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 110,
                        color: _kLight,
                        child: const Center(
                            child: Text("🍽️",
                                style: TextStyle(fontSize: 36))),
                      ),
                    )
                  : Container(
                      height: 110,
                      color: _kLight,
                      child: Center(
                          child: Text(item['image'],
                              style: const TextStyle(fontSize: 36))),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _kDark)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(item['price'] as double).toStringAsFixed(0)} HTG",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.green.shade700),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
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

  Widget _buildReviewInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bay kòmantè ou",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: _kDark)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _reviewRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < _reviewRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Ekri eksperyans ou...",
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFFAFAF9),
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitReview,
              child: const Text("Soumèt kòmantè",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(_Review rev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _kLight, shape: BoxShape.circle),
                child: const Center(
                    child: Icon(Icons.person, color: _kPrimary, size: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rev.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _kDark)),
                    Text(rev.date,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < rev.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 13,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(rev.comment,
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _Review {
  final String name;
  final int rating;
  final String comment;
  final String date;
  const _Review(this.name, this.rating, this.comment, this.date);
}

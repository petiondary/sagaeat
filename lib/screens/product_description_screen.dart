import 'package:flutter/material.dart';
import '../models/cart_service.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);

class ProductDescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDescriptionScreen({super.key, required this.product});

  @override
  State<ProductDescriptionScreen> createState() =>
      _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  int _quantity = 1;
  int _userRating = 0;
  final _allergyController = TextEditingController();
  final _commentController = TextEditingController();

  final int _prepTime = 25;
  final double _deliveryFee = 0.0;
  final double _rating = 4.5;

  final List<Map<String, dynamic>> _accompaniments = [
    {"id": 1, "name": "Sòs Pikliz", "price": 50.0, "selected": false},
    {"id": 2, "name": "Boutey Piman Bouk", "price": 75.0, "selected": false},
    {"id": 3, "name": "Bannann Peze plus", "price": 100.0, "selected": false},
  ];

  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  String _maskName(String name) {
    return name.split(' ').map((w) {
      if (w.length <= 2) return w;
      return '${w[0]}${'*' * (w.length - 2)}${w[w.length - 1]}';
    }).join(' ');
  }

  void _submitReview() {
    if (_userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tanpri bay pwen ou anvan (1-5 zetwal)."),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Kòmantè a obligatwa lè w ap bay yon pwen."),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("✓ Kòmantè ou soumèt avèk siksè. Mèsi!"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    setState(() => _userRating = 0);
    _commentController.clear();
  }

  void _calculateTotal() {
    final base = (widget.product["price"] as num?)?.toDouble() ?? 500.0;
    final extras = _accompaniments
        .where((a) => a["selected"] == true)
        .fold(0.0, (sum, a) => sum + (a["price"] as double));
    setState(() => _totalPrice = (base + extras) * _quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero header ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: _kPrimary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF78350F),
                          _kPrimary,
                          Color(0xFFD97706),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -10,
                          bottom: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: _buildProductImage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Text(
                  widget.product["name"] ?? "Detay Pla",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + restaurant
                      Text(
                        widget.product["name"] ?? "Pla Spesyal",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _kDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 15,
                            color: _kPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.product["restaurant"] ?? "Restoran SagaEat",
                            style: const TextStyle(
                              fontSize: 14,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Info chips row
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.timer_outlined,
                            label: "$_prepTime min",
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          _buildInfoChip(
                            icon: Icons.delivery_dining_outlined,
                            label: _deliveryFee == 0
                                ? "Livrezon Gratis"
                                : "$_deliveryFee HTG",
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          _buildInfoChip(
                            icon: Icons.star_rounded,
                            label: "$_rating",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildSection(
                        title: "Deskripsyon",
                        child: Text(
                          widget.product["description"] ??
                              widget.product["desc"] ??
                              "Pa gen deskripsyon pou pla sa a.",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Accompaniments
                      _buildSection(
                        title: "Ajoute Akonpanyeman",
                        subtitle: "Chwazi opsyon siplemantè ou vle",
                        child: Column(
                          children: _accompaniments.map((acc) {
                            final selected = acc["selected"] == true;
                            return GestureDetector(
                              onTap: () {
                                setState(() => acc["selected"] = !selected);
                                _calculateTotal();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? _kLight : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? _kPrimary
                                        : Colors.grey.shade200,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? _kPrimary
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected
                                                  ? _kPrimary
                                                  : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: selected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 13,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          acc["name"],
                                          style: TextStyle(
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14,
                                            color: _kDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "+ ${acc["price"]} HTG",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Allergy note
                      _buildSection(
                        title: "Alèji & Nòt",
                        subtitle: "Ekri si gen yon bagay ou pa manje",
                        child: TextField(
                          controller: _allergyController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Egz: san piman, san zonyon...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: _kPrimary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Reviews
                      _buildSection(
                        title: "Dènye Kòmantè yo",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReviewCard(
                              name: "Jean Baptiste",
                              comment:
                                  "Bouyon sa a se pi bon bouyon m manje nan zòn lan! M rekòmande l.",
                              rating: 5.0,
                            ),
                            const SizedBox(height: 10),
                            _buildReviewCard(
                              name: "Marie Claire",
                              comment:
                                  "Sèvis rapid, pla cho, bon prezantasyon. M ap retounen!",
                              rating: 4.5,
                            ),
                            const SizedBox(height: 16),
                            // Star rating row
                            Text(
                              "Bay pwen ou:",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (i) {
                                final filled = i < _userRating;
                                return GestureDetector(
                                  onTap: () => setState(() => _userRating = i + 1),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: filled ? Colors.amber : Colors.grey.shade300,
                                      size: 36,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            // Comment field (mandatory when rating)
                            TextField(
                              controller: _commentController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Ekri kòmantè ou a (obligatwa)...",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(14)),
                                  borderSide: BorderSide(color: _kPrimary, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _submitReview,
                                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                                label: const Text(
                                  "Soumèt Kòmantè",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom bar ────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity selector
                  Container(
                    decoration: BoxDecoration(
                      color: _kLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildQtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                              _calculateTotal();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "$_quantity",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _kDark,
                            ),
                          ),
                        ),
                        _buildQtyButton(
                          icon: Icons.add,
                          onTap: () {
                            setState(() => _quantity++);
                            _calculateTotal();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Add to cart button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        CartService.add(
                          widget.product,
                          _quantity,
                          _totalPrice,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "✓ $_quantity × ${widget.product['name']} ajoute nan panyen!",
                            ),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Ajoute nan Panyen  •  ${_totalPrice.toStringAsFixed(0)} HTG",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = widget.product["image"] as String?;
    final isUrl = imageUrl != null && imageUrl.startsWith("http");

    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Text("🍲", style: TextStyle(fontSize: 80)),
        ),
      );
    }

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(imageUrl ?? "🍲", style: const TextStyle(fontSize: 64)),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _kDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String comment,
    required double rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _kLight,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _maskName(name),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                  const SizedBox(width: 3),
                  Text(
                    "$rating",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: _kPrimary),
      ),
    );
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}

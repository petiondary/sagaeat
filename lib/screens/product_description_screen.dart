import 'package:flutter/material.dart';

class ProductDescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDescriptionScreen({super.key, required this.product});

  @override
  State<ProductDescriptionScreen> createState() =>
      _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  // Kantite pla moun nan chwazi (panyen dinamik)
  int _quantity = 1;

  // Nòt pou alèji
  final _allergyController = TextEditingController();
  final _commentController = TextEditingController();

  // Done pou akonpanyeman ak detay (Soti nan SuperAdmin)
  final int _prepTime = 25; // Variable an minit
  final double _deliveryFee =
      0.0; // Si li egal ak 0, l ap afiche "Livraison Gratuite"
  final double _rating = 4.5; // Mwayèn zetwal yo

  // Lis akonpanyeman tès (sa superadmin nan ap ka ajoute ak pri pa yo)
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

  // Kalkile pri total la an fonksyon de kantite ak akonpanyeman
  void _calculateTotal() {
    double basePrice = widget.product["price"] ?? 500.0;
    double extraPrice = 0.0;

    for (var acc in _accompaniments) {
      if (acc["selected"] == true) {
        extraPrice += acc["price"];
      }
    }

    setState(() {
      _totalPrice = (basePrice + extraPrice) * _quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product["name"] ?? "Detay Pla",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imaj oswa Emoji gwo nèt
            Center(
              child: Text(
                widget.product["image"] ?? "🍲",
                style: const TextStyle(fontSize: 80),
              ),
            ),
            const SizedBox(height: 16),

            // Non Pwodwi ak Non Restoran
            Text(
              widget.product["name"] ?? "Pla Spesyal",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.product["restaurant"] ?? "Restoran SagaEat",
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber[900],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // INFO PREPARASYON, LIVREZON AK RATING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tan preparasyon (Variable soti nan SuperAdmin)
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "$_prepTime min",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Frais de livraison (Gratis si egal ak 0)
                Row(
                  children: [
                    const Icon(
                      Icons.delivery_dining,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _deliveryFee == 0
                          ? "Livraison Gratuite"
                          : "$_deliveryFee HTG",
                      style: TextStyle(
                        color: _deliveryFee == 0 ? Colors.green : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Rating ak Zetwal (Mwayèn)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "$_rating",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),

            // Deskripsyon Pla a
            const Text(
              "Deskripsyon",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.product["description"] ??
                  "Pa gen deskripsyon pou pla sa a.",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const Divider(height: 30),

            // AJOUTE AKONPANYEMAN (Variables nan SuperAdmin)
            const Text(
              "Ajoute Akonpanyeman",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Chwazi opsyon siplemantè ou vle mete sou pla w la.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ..._accompaniments.map((acc) {
              return CheckboxListTile(
                title: Text(acc["name"]),
                secondary: Text(
                  "+ ${acc["price"]} HTG",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: acc["selected"],
                activeColor: Colors.amber[800],
                onChanged: (bool? value) {
                  setState(() {
                    acc["selected"] = value;
                  });
                  _calculateTotal();
                },
              );
            }).toList(),
            const Divider(height: 30),

            // MEMO ALÈJI AK NÒT
            const Text(
              "Èske w fè alèji ak yon bagay?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _allergyController,
              decoration: InputDecoration(
                hintText:
                    "Ekri si gen yon bagay ou pa manje (Egz: san piman, san zonyon...)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const Divider(height: 30),

            // ESPAS FEEDBACK COMMENT
            const Text(
              "Dènye kòmantè yo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Egzanp dènye kòmantè ki te fèt
            Card(
              color: Colors.grey[100],
              child: const ListTile(
                leading: CircleAvatar(child: Text("J")),
                title: Text("Jean Baptiste"),
                subtitle: Text(
                  "Bouyon sa a se pi bon bouyon m manje nan zòn lan! M rekòmande l.",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    Text("5.0"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Mete yon kòmantè oswa bay pwen pa w...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ), // Espas pou bouton ki anba a pa kache kòd la
          ],
        ),
      ),

      // BOTOM BAR : PANYEN DINAMIK AK BOUTON SÈVI
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton Plis ak Mwens (+ / -)
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 30,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                      _calculateTotal();
                    }
                  },
                ),
                Text(
                  "$_quantity",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                    _calculateTotal();
                  },
                ),
              ],
            ),

            // Bouton Ajoute nan panyen ak Pri Total la dinamik
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Ajoute nan panyen : $_quantity ${widget.product['name']} pou ${_totalPrice.toStringAsFixed(2)} HTG",
                    ),
                  ),
                );
              },
              child: Text(
                "Ajoute (${_totalPrice.toStringAsFixed(2)} HTG)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
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

import 'package:flutter/material.dart';
import 'product_description_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index pou jere ki paj ki chwazi nan Footer a (Default se Home = 0)
  int _currentIndex = 0;

  // Statut KYC kliyan an (Si se false, li pa ka pase kòmand)
  bool _isAccountVerified = false;

  // Controller pou PageView horizontal la pou jere fluidité a ak efè snapping lan
  final PageController _pageController = PageController(viewportFraction: 0.92);

  // Fo done k ap simulation yon rekèt database ki rale pla ki nan Komin Carrefour
  final Map<String, dynamic> nearestProduct = {
    "name": "Bouyon Spesyal Kreyòl",
    "restaurant": "Restoran Mèt Dary - Carrefour",
    "description":
        "Pla sa a disponib toupre w nan komin ou an! Byen ranpli ak bon vyann ak legim fre.",
    "price": 500.0,
    "image": "https://www.pngmart.com/files/16/Cheese-Burger-PNG-Photos.png",
  };

  final List<Map<String, dynamic>> availableMenu = [
    {
      "name": "Burger Kreyòl Double",
      "restaurant": "Chit Chat Fastfood",
      "price": 350.0,
      "image": "🍔",
      "desc": "Double patek avèk bon pikliz ak sòs kreyòl.",
    },
    {
      "name": "Pizza Pòtoprens",
      "restaurant": "Lakay Pizza",
      "price": 750.0,
      "image": "🍕",
      "desc": "Fwomaj lokal, janbon, piman ak zonyon fre.",
    },
    {
      "name": "Fritay Pwason",
      "restaurant": "Bò Lanmè Resto",
      "price": 1200.0,
      "image": "🐟",
      "desc": "Bon pwason fri ak bannann peze, akra, ak pikliz.",
    },
  ];

  // SIMILASYON REKÈT DATABASE POU RESTORAN KI TOUPRE YO (Pou ranpli ti vid la)
  final List<Map<String, dynamic>> nearbyRestaurants = [
    {
      "name": "Restoran Mèt Dary",
      "address": "Carrefour, Kafou Rit, Monrepos 42",
      "desc":
          "Espesyalite nou se bon manje kreyòl lakay, bouyon tèt chaje chak samdi, ak bon kalite sèvis rapid ak sekirite total.",
      "logo": "🏪",
    },
    {
      "name": "Chit Chat Fastfood",
      "address": "Carrefour, Diko, Wout nasyonal #2",
      "desc":
          "Pi bon burger, pitza, ak fritay nan zòn nan. Vin pase yon bèl moman oswa kòmande depi lakay ou.",
      "logo": "🍔",
    },
    {
      "name": "Lakay Pizza",
      "address": "Carrefour, Waney 93, Toupre plas la",
      "desc":
          "Nou kwit pitza nou yo ak bwa pou vrè gou tradisyonèl la. Tout engredyan nou yo se pwodwi lokal fre.",
      "logo": "🍕",
    },
  ];

  // NOUVO: DONE SIMILASYON POU ISTORIK TRANSAKSYON AK STATU KÒMAND YO
  final List<Map<String, dynamic>> transactionHistory = [
    {
      "order_id": "ORD-2026-8941",
      "item": "Bouyon Spesyal Kreyòl",
      "restaurant": "Restoran Mèt Dary",
      "price": 500.0,
      "date": "Jodi a, 4:04 PM",
      "status": "En cours", // Kòmand ankou
    },
    {
      "order_id": "ORD-2026-7532",
      "item": "Pizza Pòtoprens",
      "restaurant": "Lakay Pizza",
      "price": 750.0,
      "date": "Ayè, 7:15 PM",
      "status": "En préparation", // Kòmand an preparasyon
    },
    {
      "order_id": "ORD-2026-4122",
      "item": "Burger Kreyòl Double",
      "restaurant": "Chit Chat Fastfood",
      "price": 350.0,
      "date": "18 Me 2026",
      "status": "Annulé", // Kòmand anile
    },
    {
      "order_id": "ORD-2026-3011",
      "item": "Fritay Pwason",
      "restaurant": "Bò Lanmè Resto",
      "price": 1200.0,
      "date": "15 Me 2026",
      "status": "Livré", // Livrezon fini
    },
  ];

  // METÒD KI POU BLOKE AKASYON KÒMAND LAN SI ITILIZATÈ A PA VERIFYE KYC
  void _verfiyKycAndNavigate(Map<String, dynamic> product) {
    if (!_isAccountVerified) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.gpp_maybe, color: Colors.red, size: 50),
          title: const Text(
            "Verifikasyon KYC Obligatwa",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Poutèt rezon sekirite an Ayiti, ou dwe verifye kont ou anvan ou kapab pase yon kòmand sou SagaEat. Tanpri ale nan pwofil ou pou w soumèt pyès ou (CIN / NIF / Paspò).",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anile"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex =
                      3; // Mizajou: Navige sou paj Pwofil la (ki pase nan index 3 kounye a)
                });
              },
              child: const Text(
                "Fè KYC Kounye a",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDescriptionScreen(product: product),
        ),
      );
    }
  }

  // METÒD POU RANN KONTNI KÒ A DINAMIK SELON PAJ KI SELEKSYONE A
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildSearchContent();
      case 2:
        return _buildHistoryContent(); // NOUVO: Onglet Istorik Transaksyon
      case 3:
        return _buildProfileContent();
      case 4:
        return _buildSettingsContent(); // Louvri apati ikòn ki nan AppBar a
      default:
        return _buildHomeContent();
    }
  }

  // 1. PAJ HOME
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GWO BANNER - AVÈK PLAS IMAJ RESTORAN
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[800]!, Colors.orange[700]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "📍 Pi pre w",
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        nearestProduct["image"],
                        height: 65,
                        width: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            "🍔",
                            style: TextStyle(fontSize: 40),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  nearestProduct["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  nearestProduct["restaurant"],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nearestProduct["description"],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${nearestProduct["price"]} HTG",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.amber[800],
                      ),
                      onPressed: () => _verfiyKycAndNavigate(nearestProduct),
                      child: const Text(
                        "Achte Kounye a",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Meni ki disponib toupre w",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // PAGEVIEW PLA HORIZONTAL (SMOOTH SNAPPING)
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: 10000,
              itemBuilder: (context, index) {
                final item = availableMenu[index % availableMenu.length];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 6.0,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _verfiyKycAndNavigate(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item["image"],
                                  style: const TextStyle(fontSize: 34),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${item["price"]} HTG",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item["name"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["restaurant"],
                              style: TextStyle(
                                color: Colors.amber[900],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                item["desc"],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // RANPLI VID LAN AK RESTORAN KI TOUPRE YO (LISTE VÈTIKAL)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Restoran ki toupre w",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nearbyRestaurants.length,
            itemBuilder: (context, index) {
              final resto = nearbyRestaurants[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          resto["logo"],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resto["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    resto["address"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resto["desc"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // 2. PAJ RECHÈCH
  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kisa w ap chache jodi a? 🤔",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "chache on pla , bwason , restoran , on zone",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.amber),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.amber[800]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Kategori popilè",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              Chip(
                label: const Text("🍲 Bouyon"),
                backgroundColor: Colors.amber[50],
              ),
              Chip(
                label: const Text("🍔 Burgers"),
                backgroundColor: Colors.amber[50],
              ),
              Chip(
                label: const Text("🍕 Pizza"),
                backgroundColor: Colors.amber[50],
              ),
              Chip(
                label: const Text("🥤 Bwason"),
                backgroundColor: Colors.amber[50],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NOUVO: 3. KOÒDONE PAJ ISTORIK TRANSAKSYON AK CHIP KOULÈ POU STATU YO
  Widget _buildHistoryContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: transactionHistory.length,
      itemBuilder: (context, index) {
        final tx = transactionHistory[index];

        // Konfigirasyon koulè chip la selon statu kòmand lan pou l ka pwofesyonèl
        Color statusColor = Colors.grey;
        Color statusBg = Colors.grey[100]!;

        if (tx["status"] == "En cours") {
          statusColor = Colors.blue[800]!;
          statusBg = Colors.blue[50]!;
        } else if (tx["status"] == "En préparation") {
          statusColor = Colors.orange[800]!;
          statusBg = Colors.orange[50]!;
        } else if (tx["status"] == "Annulé") {
          statusColor = Colors.red[800]!;
          statusBg = Colors.red[50]!;
        } else if (tx["status"] == "Livré") {
          statusColor = Colors.green[800]!;
          statusBg = Colors.green[50]!;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx["order_id"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tx["status"],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  tx["item"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx["restaurant"],
                  style: TextStyle(
                    color: Colors.amber[900],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx["date"],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Text(
                      "${tx["price"]} HTG",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. PAJ PWOFIL
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.amber[700],
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.amber[800],
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Chwazi yon nouvo foto pwofil nan galri...",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Card(
            color: _isAccountVerified ? Colors.green[50] : Colors.red[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    _isAccountVerified ? Icons.verified_user : Icons.gpp_bad,
                    color: _isAccountVerified ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAccountVerified
                              ? "Kont Verifye (KYC Apwouve)"
                              : "Kont lan Poko Verifye",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isAccountVerified
                                ? Colors.green[900]
                                : Colors.red[900],
                          ),
                        ),
                        Text(
                          _isAccountVerified
                              ? "Ou kapab pase tout kòmand ou yo san pwoblèm."
                              : "Tanpri soumèt pyès idantite w pou debloque kòmand yo.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isAccountVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                      ),
                      onPressed: () {
                        setState(() {
                          _isAccountVerified = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Siksè! Dokiman KYC soumèt epi apwouve.",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Verifye l",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: "Non & Prenon (Bloke)",
              prefixIcon: const Icon(Icons.lock, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Colors.grey[100],
              filled: true,
            ),
            controller: TextEditingController(text: "Dary Sebastien Petion"),
          ),
          const SizedBox(height: 16),

          TextField(
            decoration: InputDecoration(
              labelText: "Adrès Livrezon",
              prefixIcon: const Icon(Icons.location_on, color: Colors.amber),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: TextEditingController(
              text: "Carrefour, Monrepos, Kay Ble",
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Nimewo Telefòn",
              prefixIcon: const Icon(Icons.phone, color: Colors.amber),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: TextEditingController(text: "+509 3xxx-xxxx"),
          ),
          const SizedBox(height: 16),

          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: const Icon(Icons.email, color: Colors.amber),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: TextEditingController(text: "petiondary@gmail.com"),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pwofil mete ajou avèk siksè!")),
                );
              },
              child: const Text(
                "Anrejistre Chanjman yo",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. PAJ PARAMÈT (LOUVRI APATI IKÒN APBAR A)
  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.amber),
            title: const Text("Notifikasyon Kòmand"),
            subtitle: const Text("Resevwa alèt lè eta kòmand ou chanje"),
            trailing: Switch(
              value: true,
              activeColor: Colors.amber[800],
              onChanged: (val) {},
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language, color: Colors.amber),
            title: const Text("Lang Aplikasyon an"),
            subtitle: const Text("Kreyòl Ayisyen"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.red[50],
          child: ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              "Dekonekte",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.fastfood, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _currentIndex == 0
                  ? "SagaEat"
                  : _currentIndex == 1
                  ? "Rechèch"
                  : _currentIndex == 2
                  ? "Istorik Acha"
                  : _currentIndex == 3
                  ? "Pwofil mwen"
                  : "Paramètres",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[800],
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {},
            ),
          // Bouton Paramètres anlè a pou ouvri nèt san bloke Footer a
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              setState(() {
                _currentIndex = 4; // Filtre sou paramètre
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 3
            ? 0
            : _currentIndex, // Kenbe ansyen eta vizyèl la si nou nan paramètres
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Istorik",
          ), // NOUVO
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

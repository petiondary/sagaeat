import 'package:flutter/material.dart';
import 'home_screen.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kSecondary = Color(0xFFD97706);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _houseDetailsController = TextEditingController();
  final _birthDateController = TextEditingController();

  final List<String> _departments = [
    "Artibonite",
    "Centre",
    "Grand'Anse",
    "Nippes",
    "Nord",
    "Nord-Est",
    "Nord-Ouest",
    "Ouest",
    "Sud",
    "Sud-Est",
  ];
  String? _selectedDepartment;

  final List<String> _communes = [
    "Carrefour",
    "Delmas",
    "Pétion-Ville",
    "Tabarre",
    "Port-au-Prince",
  ];
  String? _selectedCommune;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLogin = !_isLogin);
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Column(
        children: [
          // ── Header gradient ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              28,
              MediaQuery.of(context).padding.top + 24,
              28,
              36,
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "SagaEat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _isLogin ? "Bònjou, \nRetounen! 👋" : "Kreye\nKont Ou",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? "Konekte pou kòmande manje ou renmen."
                      : "Enskri pou kòmanse pase kòmand nan zòn ou.",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Form section ─────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLogin) ...[
                      _buildField(
                        controller: _nameController,
                        label: "Non konplè",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                    ],

                    _buildField(
                      controller: _emailController,
                      label: "Adrès Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _phoneController,
                      label: "Nimewo Telefòn",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    if (!_isLogin) ...[
                      _buildField(
                        controller: _birthDateController,
                        label: "Dat nesans (JJ/MM/AAAA)",
                        icon: Icons.cake_outlined,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionLabel("📍 Konfigirasyon Adrès (Ayiti)"),
                      const SizedBox(height: 14),

                      _buildDropdown(
                        label: "Depatman",
                        icon: Icons.map_outlined,
                        value: _selectedDepartment,
                        items: _departments,
                        onChanged: (v) =>
                            setState(() => _selectedDepartment = v),
                      ),
                      const SizedBox(height: 14),

                      _buildDropdown(
                        label: "Komin",
                        icon: Icons.location_city_outlined,
                        value: _selectedCommune,
                        items: _communes,
                        onChanged: (v) => setState(() => _selectedCommune = v),
                      ),
                      const SizedBox(height: 14),

                      _buildField(
                        controller: _cityController,
                        label: "Vil / Zòn / Katye",
                        icon: Icons.nature_people_outlined,
                      ),
                      const SizedBox(height: 14),

                      _buildField(
                        controller: _houseDetailsController,
                        label: "Detay Kay (nimewo, baryè, apatman...)",
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                    ],

                    const SizedBox(height: 8),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          _isLogin ? "Konekte" : "Kreye Kont",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Toggle login/register
                    Center(
                      child: GestureDetector(
                        onTap: _toggleMode,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            children: [
                              TextSpan(
                                text: _isLogin
                                    ? "Ou poko gen kont? "
                                    : "Ou gen kont deja? ",
                              ),
                              TextSpan(
                                text: _isLogin ? "Enskri la a" : "Konekte w",
                                style: const TextStyle(
                                  color: _kPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1C1917),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary, size: 20),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary, size: 20),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kPrimary, width: 2),
        ),
      ),
      items: items
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _houseDetailsController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_repository.dart';
import '../data/haiti_geo.dart';
import 'home_screen.dart';

const Color _kPrimary   = Color(0xFFB45309);
const Color _kSecondary = Color(0xFFD97706);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {

  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;

  // ── Controllers ───────────────────────────────────────────────
  final _nameCtrl        = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _birthDateCtrl   = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _houseDetailsCtrl= TextEditingController();

  String? _selectedDepartment;
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

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _birthDateCtrl.dispose();
    _cityCtrl.dispose();
    _houseDetailsCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLogin = !_isLogin);
    _animController.forward();
  }

  // ── Submit ────────────────────────────────────────────────────
  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (!email.contains('@')) { _snack('Tanpri antre yon imèl valid.'); return; }
    if (pass.length < 6)       { _snack('Modpas dwe gen omwen 6 karaktè.'); return; }

    if (!_isLogin) {
      if (_nameCtrl.text.trim().isEmpty) { _snack('Antre non ou.'); return; }
      if (_phoneCtrl.text.trim().isEmpty){ _snack('Antre nimewo telefòn ou.'); return; }
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await AuthRepository.login(email: email, password: pass);
      } else {
        // Konvèti dat JJ/MM/AAAA → YYYY-MM-DD
        String? birthDate;
        final raw = _birthDateCtrl.text.trim();
        if (raw.contains('/')) {
          final parts = raw.split('/');
          if (parts.length == 3) birthDate = '${parts[2]}-${parts[1]}-${parts[0]}';
        }

        await AuthRepository.register(
          name:      _nameCtrl.text.trim(),
          email:     email,
          phone:     _phoneCtrl.text.trim(),
          password:  pass,
          birthDate: birthDate ?? '',
          department: _selectedDepartment ?? '',
          commune:    _selectedCommune    ?? '',
          city:       _cityCtrl.text.trim(),
          houseDetails: _houseDetailsCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Erè rezo. Verifye koneksyon ou.';
      if (e.response?.statusCode == 401) msg = 'Email oswa modpas pa kòrèk.';
      else if (e.response?.statusCode == 422) {
        final errors = data?['errors'] as Map?;
        if (errors != null) {
          msg = (errors.values.first as List).first.toString();
        } else {
          msg = data?['message'] ?? msg;
        }
      }
      _snack(msg, error: true);
    } catch (_) {
      _snack('Erè etranj. Eseye ankò.', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Column(
        children: [
          // Header gradient
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
                bottomLeft:  Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.fastfood, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text("SagaEat",
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ]),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? "Bònjou,\nRetounen! 👋" : "Kreye\nKont Ou",
                  style: const TextStyle(color: Colors.white, fontSize: 30,
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? "Konekte pou kòmande manje ou renmen."
                      : "Enskri pou kòmanse pase kòmand.",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Register only fields ──────────────────────
                    if (!_isLogin) ...[
                      _field(_nameCtrl, "Non konplè", Icons.person_outline),
                      const SizedBox(height: 14),
                    ],

                    // ── Email (toujou) ────────────────────────────
                    _field(_emailCtrl, "Adrès Email", Icons.email_outlined,
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 14),

                    // ── Telefòn (enskrisyon sèlman) ───────────────
                    if (!_isLogin) ...[
                      _field(_phoneCtrl, "Nimewo Telefòn", Icons.phone_outlined,
                          type: TextInputType.phone),
                      const SizedBox(height: 14),
                      _field(_birthDateCtrl, "Dat nesans (JJ/MM/AAAA)",
                          Icons.cake_outlined),
                      const SizedBox(height: 14),
                    ],

                    // ── Modpas (toujou) ───────────────────────────
                    _passwordField(),
                    const SizedBox(height: 14),

                    // ── Adrès (enskrisyon sèlman) ─────────────────
                    if (!_isLogin) ...[
                      _sectionLabel("📍 Adrès (Ayiti)"),
                      const SizedBox(height: 14),
                      _dropdown(
                        label: "Depatman",
                        icon: Icons.map_outlined,
                        value: _selectedDepartment,
                        items: haitiGeo.keys.toList(),
                        onChanged: (v) => setState(() {
                          _selectedDepartment = v;
                          _selectedCommune    = null;
                        }),
                      ),
                      const SizedBox(height: 14),
                      _dropdown(
                        label: "Komin",
                        icon: Icons.location_city_outlined,
                        value: _selectedCommune,
                        items: _selectedDepartment != null
                            ? (haitiGeo[_selectedDepartment] ?? [])
                            : [],
                        onChanged: (v) => setState(() => _selectedCommune = v),
                      ),
                      const SizedBox(height: 14),
                      _field(_cityCtrl, "Vil / Zòn / Katye",
                          Icons.nature_people_outlined),
                      const SizedBox(height: 14),
                      _field(_houseDetailsCtrl,
                          "Detay Kay (nimewo, baryè, apatman...)",
                          Icons.home_outlined,
                          maxLines: 2),
                      const SizedBox(height: 14),
                    ],

                    const SizedBox(height: 8),

                    // ── Bouton submit ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                _isLogin ? "Konekte" : "Kreye Kont",
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Toggle login / register ───────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _toggleMode,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                            children: [
                              TextSpan(
                                  text: _isLogin
                                      ? "Ou pa gen kont? "
                                      : "Ou deja gen kont? "),
                              TextSpan(
                                text: _isLogin ? "Enskri la a" : "Konekte w",
                                style: const TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.bold),
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

  // ── Widgets helpers ───────────────────────────────────────────

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 2)),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passCtrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: "Modpas",
        prefixIcon: const Icon(Icons.lock_outline, color: _kPrimary),
        suffixIcon: IconButton(
          icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 2)),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 2)),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
            letterSpacing: 0.3));
  }
}

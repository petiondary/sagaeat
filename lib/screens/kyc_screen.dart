import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kyc_service.dart';

const Color _kPrimary = Color(0xFFB45309);
const Color _kDark = Color(0xFF1C1917);
const Color _kLight = Color(0xFFFFF7ED);

enum _DocType { carteIdentite, permis, passeport }

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0=intro 1=personal 2=docChoice 3=docPhotos 4=selfie 5=success

  // Personal info
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _lieuNaissCtrl = TextEditingController();
  DateTime? _dateNaissance;

  // Document
  _DocType? _docType;
  File? _docRecto;
  File? _docVerso;
  File? _selfie;

  // Processing animation
  late AnimationController _spinCtrl;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    // Recover photo if Android killed the app while camera was open
    _recoverLostData();
  }

  Future<void> _recoverLostData() async {
    final lost = await _picker.retrieveLostData();
    if (lost.isEmpty || lost.file == null) return;
    if (!mounted) return;
    final file = File(lost.file!.path);
    setState(() {
      if (_step == 4) {
        _selfie = file;
      } else if (_step == 3) {
        _docRecto ??= file;
      }
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _lieuNaissCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────

  void _next() => setState(() => _step++);
  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  bool get _personalValid =>
      _nomCtrl.text.trim().isNotEmpty &&
      _prenomCtrl.text.trim().isNotEmpty &&
      _dateNaissance != null &&
      _lieuNaissCtrl.text.trim().isNotEmpty;

  bool get _docPhotosValid {
    if (_docType == null) return false;
    if (_docType == _DocType.carteIdentite) {
      return _docRecto != null && _docVerso != null;
    }
    return _docRecto != null;
  }

  // ── Photo picker ───────────────────────────────────────────────

  Future<void> _pickPhoto(bool isRecto) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text("Chwazi sous foto",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _sourceBtn(Icons.camera_alt_rounded, "Pran foto",
                ImageSource.camera, isRecto),
            const SizedBox(height: 10),
            _sourceBtn(Icons.photo_library_rounded, "Galeri aparèy",
                ImageSource.gallery, isRecto),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sourceBtn(
      IconData icon, String label, ImageSource src, bool isRecto) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final picked = await _picker.pickImage(source: src, imageQuality: 90);
        if (picked == null) return;
        setState(() {
          if (isRecto) {
            _docRecto = File(picked.path);
          } else {
            _docVerso = File(picked.path);
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: _kLight, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _kPrimary, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: _kDark, fontSize: 14)),
        ]),
      ),
    );
  }

  Future<void> _pickSelfie() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _selfie = File(picked.path));
  }

  // ── Date picker ────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: Column(
        children: [
          _buildHeader(),
          if (_step < 5) _buildProgressBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const titles = [
      'Verifikasyon KYC',
      'Enfòmasyon Pèsonèl',
      'Tip Pyès Idantite',
      'Foto Pyès',
      'Foto Vizaj',
      'Tès Vitalite',
      'Analizyon...',
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF78350F), _kPrimary, Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _step < titles.length ? titles[_step] : '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (_step > 0 && _step < 5)
                Text('$_step/4',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_step == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: _step / 5,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
          minHeight: 5,
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildIntro();
      case 1:
        return _buildPersonalInfo();
      case 2:
        return _buildDocChoice();
      case 3:
        return _buildDocPhotos();
      case 4:
        return _buildSelfie();
      case 5:
        return _buildSuccess();
      default:
        return const SizedBox();
    }
  }

  // ── Step 0: Intro ──────────────────────────────────────────────

  Widget _buildIntro() {
    final items = [
      (Icons.badge_outlined, 'Pyès idantite valid',
          'Carte identité, Permis ou Paspò'),
      (Icons.face_retouching_natural, 'Vizaj ou',
          'Bon limyè, san lunet nwa, pa kouvri figi'),
      (Icons.videocam_outlined, 'Kamera ki fonksyone',
          'Pou pran foto ak videyo liveness'),
      (Icons.signal_wifi_4_bar, 'Koneksyon entènèt',
          'Pou voye done yo ak sekirite'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration:
                  const BoxDecoration(color: _kLight, shape: BoxShape.circle),
              child: const Icon(Icons.shield_outlined,
                  size: 56, color: _kPrimary),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Pou kisa nou bezwen KYC?",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: _kDark)),
          const SizedBox(height: 8),
          Text(
            "Pou rezon sekirite ak prevansyon fwod, nou dwe verifye idantite ou "
            "anvan ou kapab pase kòmand. Pwosesis la pran 2-3 minit.",
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text("Sa ou bezwen:",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _kDark)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: _kLight, shape: BoxShape.circle),
                      child: Icon(item.$1, color: _kPrimary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _kDark)),
                          const SizedBox(height: 2),
                          Text(item.$3,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 28),
          _primaryBtn("Kòmanse Verifikasyon", _next),
        ],
      ),
    );
  }

  // ── Step 1: Personal info ──────────────────────────────────────

  Widget _buildPersonalInfo() {
    final dateStr = _dateNaissance == null
        ? null
        : '${_dateNaissance!.day.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.month.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.year}';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Enfòmasyon Biometrik"),
          const SizedBox(height: 4),
          Text(
            "Antre done yo EGZAKTEMAN jan yo parèt sou pyès idantite ou a.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _field("Nom (Siyati)", "BAPTISTE", _nomCtrl,
              icon: Icons.person_outline),
          const SizedBox(height: 14),
          _field("Prenon", "Jean", _prenomCtrl,
              icon: Icons.person_outline),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _dateNaissance != null
                        ? _kPrimary
                        : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18,
                      color: _dateNaissance != null
                          ? _kPrimary
                          : Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Text(
                    dateStr ?? "Dat Nesans (jj/mm/aaaa)",
                    style: TextStyle(
                        fontSize: 14,
                        color: dateStr != null
                            ? _kDark
                            : Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _field("Kote ou Fèt (Komin / Vil)", "Carrefour, Ouest",
              _lieuNaissCtrl,
              icon: Icons.location_city_outlined),
          const SizedBox(height: 28),
          _primaryBtn(
            "Kontinye",
            _personalValid ? _next : null,
          ),
        ],
      ),
    );
  }

  // ── Step 2: Document choice ────────────────────────────────────

  Widget _buildDocChoice() {
    final docs = [
      (
        _DocType.carteIdentite,
        'Carte Identité Nasyonal',
        'Recto + Verso obligatwa',
        Icons.credit_card_rounded,
      ),
      (
        _DocType.permis,
        'Permis de Conduire',
        'Recto sèlman',
        Icons.drive_eta_rounded,
      ),
      (
        _DocType.passeport,
        'Paspò',
        'Paj prensipal la (foto + done)',
        Icons.book_outlined,
      ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Chwazi Pyès Idantite"),
          const SizedBox(height: 4),
          Text(
            "Chwazi tip pyès ou vle itilize pou verifikasyon an.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...docs.map((doc) {
            final selected = _docType == doc.$1;
            return GestureDetector(
              onTap: () => setState(() {
                _docType = doc.$1;
                _docRecto = null;
                _docVerso = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? _kLight : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _kPrimary : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? _kPrimary
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(doc.$4,
                          color:
                              selected ? Colors.white : Colors.grey.shade500,
                          size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.$2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: selected ? _kPrimary : _kDark)),
                          const SizedBox(height: 3),
                          Text(doc.$3,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: _kPrimary, size: 22),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _primaryBtn("Kontinye", _docType != null ? _next : null),
        ],
      ),
    );
  }

  // ── Step 3: Document photos ────────────────────────────────────

  Widget _buildDocPhotos() {
    final needsVerso = _docType == _DocType.carteIdentite;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(_docType == _DocType.carteIdentite
              ? "Foto Carte Identité"
              : _docType == _DocType.permis
                  ? "Foto Permis de Conduire"
                  : "Foto Paspò"),
          const SizedBox(height: 12),
          _qualityTips(),
          const SizedBox(height: 20),
          _photoSlot(
            label: needsVerso ? "Recto (Devan)" : "Foto Pyès la",
            subtitle: "Asire tout kwen pyès la vizib",
            file: _docRecto,
            onTap: () => _pickPhoto(true),
          ),
          if (needsVerso) ...[
            const SizedBox(height: 14),
            _photoSlot(
              label: "Verso (Dèyè)",
              subtitle: "Pran dèyè pyès la tou",
              file: _docVerso,
              onTap: () => _pickPhoto(false),
            ),
          ],
          const SizedBox(height: 28),
          _primaryBtn("Kontinye", _docPhotosValid ? _next : null),
        ],
      ),
    );
  }

  Widget _qualityTips() {
    final tips = [
      (Icons.wb_sunny_outlined, "Bon limyè — pa foto nan fènwa"),
      (Icons.image_search_outlined, "Foto kle — pa flou ditou"),
      (Icons.fit_screen_outlined, "Pyès nan sant kadran an"),
      (Icons.no_flash_outlined, "Pa gen refleksyon ou glas"),
      (Icons.spellcheck_rounded, "Tèks lisib — ou kapab li klèman"),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline_rounded,
                color: Colors.blue.shade700, size: 16),
            const SizedBox(width: 6),
            Text("Konsèy pou bon foto",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(t.$1, size: 14, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t.$2,
                        style: TextStyle(
                            fontSize: 12, color: Colors.blue.shade800)),
                  ),
                ]),
              )),
        ],
      ),
    );
  }

  Widget _photoSlot({
    required String label,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: file != null ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? _kPrimary : Colors.grey.shade300,
            width: file != null ? 2 : 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: file != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: _kPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text("Tape pou chanje",
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: _kLight, shape: BoxShape.circle),
                    child: const Icon(Icons.add_a_photo_rounded,
                        color: _kPrimary, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _kDark)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  // ── Step 4: Selfie ─────────────────────────────────────────────

  Widget _buildSelfie() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Foto Vizaj ou"),
          const SizedBox(height: 4),
          Text("Foto sa a ap konpare avèk foto sou pyès idantite ou a.",
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 16),
          _selfieTips(),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickSelfie,
            child: Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: _selfie != null ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _selfie != null ? _kPrimary : Colors.grey.shade300,
                  width: _selfie != null ? 2 : 1.5,
                ),
              ),
              child: _selfie != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selfie!,
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: _kPrimary,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.circular(8)),
                              child: const Text("Tape pou chanje",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: _kLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _kPrimary.withValues(alpha: 0.3),
                                  width: 2,
                                  style: BorderStyle.solid)),
                          child: const Icon(Icons.face_retouching_natural,
                              color: _kPrimary, size: 40),
                        ),
                        const SizedBox(height: 14),
                        const Text("Tape pou pran selfie",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _kDark)),
                        const SizedBox(height: 6),
                        Text("Kamera devan rekòmande",
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 28),
          _primaryBtn("Kontinye", _selfie != null ? _next : null),
        ],
      ),
    );
  }

  Widget _selfieTips() {
    final tips = [
      (Icons.wb_sunny_outlined, "Bon limyè sou figi ou"),
      (Icons.face_outlined, "Gade dwat nan kamera a"),
      (Icons.no_photography_outlined, "Pa kouvri figi ou"),
      (Icons.remove_red_eye_outlined, "Retire lunet nwa ou"),
      (Icons.crop_free_outlined, "Tout figi nan kadran an"),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.tips_and_updates_outlined,
                color: Colors.green.shade700, size: 16),
            const SizedBox(width: 6),
            Text("Konsèy pou bon selfie",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Icon(t.$1, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t.$2,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800)),
                  ),
                ]),
              )),
        ],
      ),
    );
  }

  // ── Step 5: Success ────────────────────────────────────────────

  Widget _buildSuccess() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      KycService.markVerified();
      Navigator.pop(context, true);
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _spinCtrl,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                    color: _kLight, shape: BoxShape.circle),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: _kPrimary, size: 48),
              ),
            ),
            const SizedBox(height: 28),
            const Text("Analizyon Done yo...",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              "Nou ap verifye tout enfòmasyon ou yo. Sa pran kèk segonn.",
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: _kDark));

  Widget _field(String label, String hint, TextEditingController ctrl,
      {required IconData icon}) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _kPrimary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: _kPrimary, width: 2)),
        labelStyle: const TextStyle(color: _kPrimary),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _kPrimary : Colors.grey.shade300,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label,
            style: TextStyle(
                color: enabled ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../models/wallet_service.dart';
import '../models/kyc_service.dart';
import '../models/security_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _kPrimary = Color(0xFFB45309);

  // all | deposit | purchase | refund | gift_card | transfer_in | transfer_out
  String _filter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  List<WalletTransaction> get _filtered {
    final all = WalletService.history;
    return all.where((t) {
      if (_filter != 'all' && t.type != _filter) return false;
      if (_startDate != null) {
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        if (t.date.isBefore(start)) return false;
      }
      if (_endDate != null) {
        final end = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        if (t.date.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _kPrimary)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      } else {
        _endDate = picked;
        if (_startDate != null && _startDate!.isAfter(picked)) {
          _startDate = null;
        }
      }
    });
  }

  void _clearDates() => setState(() {
    _startDate = null;
    _endDate = null;
  });

  void _showDepositSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DepositSheet(),
    );
  }

  void _showGiftCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GiftCardSheet(onRedeemed: () => setState(() {})),
    );
  }

  void _showTransferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransferSheet(onTransferred: () => setState(() {})),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'jan',
      'feb',
      'mas',
      'avr',
      'me',
      'jen',
      'jiy',
      'out',
      'sep',
      'okt',
      'nov',
      'des',
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year} • $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EF),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildFilterSection()),
          SliverToBoxAdapter(child: _buildDateSection()),
          _buildTransactionList(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      backgroundColor: _kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD97706), Color(0xFF92400E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bous Mwen',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<double>(
                  valueListenable: WalletService.balanceNotifier,
                  builder: (_, balance, _) => Text(
                    '${balance.toStringAsFixed(0)} HTG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // 3 action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _headerBtn(
                      icon: Icons.add_rounded,
                      label: 'Depo',
                      onTap: _showDepositSheet,
                    ),
                    const SizedBox(width: 12),
                    _headerBtn(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Gift Card',
                      onTap: _showGiftCardSheet,
                    ),
                    const SizedBox(width: 12),
                    _headerBtn(
                      icon: Icons.send_rounded,
                      label: 'Transfere',
                      onTap: _showTransferSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      title: const Text(
        'Pòtmonè',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _headerBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white38),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = [
      ('all', 'Tout', Icons.swap_horiz_rounded),
      ('deposit', 'Depo', Icons.arrow_downward_rounded),
      ('purchase', 'Acha', Icons.shopping_bag_outlined),
      ('refund', 'Ranbousman', Icons.replay_rounded),
      ('gift_card', 'Gift Card', Icons.card_giftcard_rounded),
      ('transfer_in', 'Resepsyon', Icons.call_received_rounded),
      ('transfer_out', 'Ekspedisyon', Icons.call_made_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = _filter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f.$3,
                      size: 14,
                      color: selected ? Colors.white : _kPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(f.$2),
                  ],
                ),
                selected: selected,
                onSelected: (_) => setState(() => _filter = f.$1),
                selectedColor: _kPrimary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _kPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(color: _kPrimary.withValues(alpha: 0.3)),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final hasFilter = _startDate != null || _endDate != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _DateButton(
              label: _startDate == null
                  ? 'Dat Debi'
                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
              icon: Icons.calendar_today_rounded,
              onTap: () => _pickDate(true),
              active: _startDate != null,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('→', style: TextStyle(color: Color(0xFFB45309))),
          ),
          Expanded(
            child: _DateButton(
              label: _endDate == null
                  ? 'Dat Fen'
                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
              icon: Icons.calendar_today_rounded,
              onTap: () => _pickDate(false),
              active: _endDate != null,
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearDates,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final items = _filtered;
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Color(0xFFD97706),
              ),
              SizedBox(height: 12),
              Text(
                'Okenn tranzaksyon',
                style: TextStyle(
                  color: Color(0xFF78350F),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Chanje filtre ou pou wè plis',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) =>
              _TransactionCard(transaction: items[i], formatDate: _formatDate),
          childCount: items.length,
        ),
      ),
    );
  }
}

// ─── Date button ────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFB45309).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? const Color(0xFFB45309)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFB45309)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: active ? const Color(0xFF78350F) : Colors.grey,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction card ───────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final String Function(DateTime) formatDate;

  const _TransactionCard({required this.transaction, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final type = transaction.type;
    final isPositive = transaction.amount > 0;

    final Color iconBg;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case 'deposit':
        iconBg = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        icon = Icons.arrow_downward_rounded;
      case 'refund':
        iconBg = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF1D4ED8);
        icon = Icons.replay_rounded;
      case 'gift_card':
        iconBg = const Color(0xFFF3E8FF);
        iconColor = const Color(0xFF7C3AED);
        icon = Icons.card_giftcard_rounded;
      case 'transfer_in':
        iconBg = const Color(0xFFCCFBF1);
        iconColor = const Color(0xFF0D9488);
        icon = Icons.call_received_rounded;
      case 'transfer_out':
        iconBg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFD97706);
        icon = Icons.call_made_rounded;
      default: // purchase
        iconBg = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        icon = Icons.shopping_bag_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1C1917),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Peer info for transfers
                if (transaction.peer != null) ...[
                  Row(
                    children: [
                      Icon(
                        type == 'transfer_in'
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        size: 11,
                        color: iconColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          type == 'transfer_in'
                              ? 'De: ${transaction.peer}'
                              : 'Bay: ${transaction.peer}',
                          style: TextStyle(
                            fontSize: 11,
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  formatDate(transaction.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                // Transaction ID (always shown)
                Text(
                  '# ${transaction.id}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                if (transaction.orderId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Kòmand: ${transaction.orderId}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(0)} G',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isPositive
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Deposit sheet ──────────────────────────────────────────────────────────

class _DepositSheet extends StatefulWidget {
  const _DepositSheet();

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  static const _kPrimary = Color(0xFFB45309);

  final _amountCtrl = TextEditingController();

  final _methods = const [
    _PayMethod('Tranzak (Kaypa)', Icons.credit_card_rounded, Color(0xFF1D4ED8)),
    _PayMethod('MonCash', Icons.phone_android_rounded, Color(0xFFDC2626)),
    _PayMethod('Natcash', Icons.account_balance_rounded, Color(0xFF1E3A8A)),
    _PayMethod('Carte Bancaire', Icons.credit_score_rounded, Color(0xFF16A34A)),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit(String method, Color color) {
    final raw = _amountCtrl.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (amount == null || amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montan minimòm pou depo se 10 HTG'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: color),
            const SizedBox(width: 8),
            const Text(
              'Konfime Depo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF1C1917),
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'W ap depoze '),
              TextSpan(
                text: '${amount.toStringAsFixed(0)} HTG',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),
              const TextSpan(text: ' via '),
              TextSpan(
                text: method,
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
              const TextSpan(text: '. Eske ou konfime?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anile', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              WalletService.topUp(amount, method);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${amount.toStringAsFixed(0)} HTG ajoute nan pòtmonè ou!',
                  ),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Konfime'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final maxH = (screenH * 0.82 - bottom).clamp(240.0, screenH * 0.82);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottom),
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fè Depo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF78350F),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chwazi montan an epi mwayen peman ou',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Montan (HTG)',
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: _kPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary, width: 2),
                ),
                labelStyle: const TextStyle(color: _kPrimary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mwayen Peman',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF78350F),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ..._methods.map(
              (m) =>
                  _MethodTile(method: m, onTap: () => _submit(m.name, m.color)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gift card sheet ────────────────────────────────────────────────────────

class _GiftCardSheet extends StatefulWidget {
  final VoidCallback onRedeemed;
  const _GiftCardSheet({required this.onRedeemed});

  @override
  State<_GiftCardSheet> createState() => _GiftCardSheetState();
}

class _GiftCardSheetState extends State<_GiftCardSheet>
    with SingleTickerProviderStateMixin {
  static const _kPrimary = Color(0xFFB45309);

  int _tab = 0; // 0 = QR scan, 1 = manual
  bool _scanning = false;
  final _codeCtrl = TextEditingController();
  late final AnimationController _scanAnim;
  late final Animation<double> _scanPos;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanPos = Tween<double>(begin: 0, end: 1).animate(_scanAnim);
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() => _scanning = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final codes = WalletService.validGiftCardCodes;
      if (codes.isEmpty) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pa gen gift card valid disponib pou demo.'),
          ),
        );
        return;
      }
      setState(() {
        _scanning = false;
        _codeCtrl.text = codes.first;
        _tab = 1;
      });
    });
  }

  void _redeem() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Antre yon kòd gift card.')));
      return;
    }
    final error = WalletService.redeemGiftCard(code);
    if (error == 'already_used') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kòd sa a deja itilize.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (error == 'invalid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kòd gift card la pa valid. Verifye li epi eseye ankò.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    widget.onRedeemed();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gift card reklame avèk siksè! Balans ou mete ajou.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reklame Gift Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF78350F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Antre kòd ou eskanye QR gift card ou a',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Tab switcher
            Row(
              children: [
                Expanded(
                  child: _tabBtn(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Eskanye QR',
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _tabBtn(
                    icon: Icons.keyboard_rounded,
                    label: 'Antre Kòd',
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_tab == 0) ...[
              // Simulated QR scanner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  color: const Color(0xFF1A1A1A),
                  child: Stack(
                    children: [
                      // Corner markers
                      ..._corners(),
                      // Animated scan line
                      AnimatedBuilder(
                        animation: _scanPos,
                        builder: (_, _) => Positioned(
                          top: 20 + _scanPos.value * 150,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  _kPrimary,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Scan instruction
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            _scanning
                                ? 'Ap chache kòd...'
                                : 'Peze bouton pou simile eskan',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      // Tap to scan
                      if (!_scanning)
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: _simulateScan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _kPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Simile Eskan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_scanning)
                        const Center(
                          child: CircularProgressIndicator(color: _kPrimary),
                        ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Manual code entry
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Kòd Gift Card',
                  hintText: 'ex: SAGA-1000-HTG',
                  prefixIcon: const Icon(
                    Icons.card_giftcard_rounded,
                    color: _kPrimary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kPrimary, width: 2),
                  ),
                  labelStyle: const TextStyle(color: _kPrimary),
                  helperText:
                      'Kòd demo: SAGA-0500-HTG • SAGA-2500-HTG • DEMO-2026-XXX',
                  helperStyle: const TextStyle(fontSize: 10),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _tab == 0 ? null : _redeem,
                icon: const Icon(Icons.redeem_rounded),
                label: const Text(
                  'Skane Gift Card',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _kPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const size = 24.0;
    const thickness = 3.0;
    const color = Color(0xFFB45309);
    Widget corner({
      required Alignment align,
      required BorderRadius radius,
      required bool top,
      required bool left,
    }) {
      return Positioned(
        top: top ? 16 : null,
        bottom: top ? null : 16,
        left: left ? 16 : null,
        right: left ? null : 16,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border(
              top: top
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              bottom: top
                  ? BorderSide.none
                  : const BorderSide(color: color, width: thickness),
              left: left
                  ? const BorderSide(color: color, width: thickness)
                  : BorderSide.none,
              right: left
                  ? BorderSide.none
                  : const BorderSide(color: color, width: thickness),
            ),
            borderRadius: radius,
          ),
        ),
      );
    }

    return [
      corner(
        align: Alignment.topLeft,
        radius: const BorderRadius.only(topLeft: Radius.circular(6)),
        top: true,
        left: true,
      ),
      corner(
        align: Alignment.topRight,
        radius: const BorderRadius.only(topRight: Radius.circular(6)),
        top: true,
        left: false,
      ),
      corner(
        align: Alignment.bottomLeft,
        radius: const BorderRadius.only(bottomLeft: Radius.circular(6)),
        top: false,
        left: true,
      ),
      corner(
        align: Alignment.bottomRight,
        radius: const BorderRadius.only(bottomRight: Radius.circular(6)),
        top: false,
        left: false,
      ),
    ];
  }
}

// ─── Transfer sheet ─────────────────────────────────────────────────────────

class _TransferSheet extends StatefulWidget {
  final VoidCallback onTransferred;
  const _TransferSheet({required this.onTransferred});

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  static const _kPrimary = Color(0xFFB45309);

  final _recipientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  double _parsedAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() {
      final v =
          double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.')) ?? 0;
      if (v != _parsedAmount) setState(() => _parsedAmount = v);
    });
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final recipient = _recipientCtrl.text.trim();
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Antre email, username, oswa ID destinatè a.'),
        ),
      );
      return;
    }
    if (_parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Antre yon montan valid pou transfere.')),
      );
      return;
    }
    final total = _parsedAmount + WalletService.transferFee;
    if (WalletService.balance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fon ensifizèn. Ou bezwen ${total.toStringAsFixed(0)} HTG (${_parsedAmount.toStringAsFixed(0)} + ${WalletService.transferFee.toStringAsFixed(0)} frè).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // KYC check
    if (!KycService.isVerified) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(Icons.gpp_maybe, color: Colors.red.shade700, size: 36),
          title: const Text(
            'KYC Obligatwa',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: Text(
            'Ou dwe verifye idantite w (KYC) anvan ou ka transfere lajan. Ale nan Pwofil → Verifye.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Konprann',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Biometric check
    if (SecurityService.biometricEnabled) {
      final auth = LocalAuthentication();
      final canAuth =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (canAuth) {
        bool ok = false;
        try {
          ok = await auth.authenticate(
            localizedReason: 'Verifye idantite w pou konfime transfert la',
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
          );
        } catch (_) {
          ok = false;
        }
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Otantifikasyon echwe — transfert anile.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
    }

    if (!mounted) return;

    // Confirm dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send_rounded, color: _kPrimary, size: 30),
        ),
        title: const Text(
          'Konfime Transfert',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _confirmRow('Destinatè', recipient),
            _confirmRow('Montan', '${_parsedAmount.toStringAsFixed(0)} HTG'),
            _confirmRow(
              'Frè Transfert',
              '${WalletService.transferFee.toStringAsFixed(0)} HTG',
            ),
            const Divider(height: 16),
            _confirmRow(
              'Total Dedui',
              '${total.toStringAsFixed(0)} HTG',
              bold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anile', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              WalletService.transferSend(_parsedAmount, recipient);
              widget.onTransferred();
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_parsedAmount.toStringAsFixed(0)} HTG voye bay $recipient!',
                  ),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: const Text(
              'Wi, Voye',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: bold ? _kPrimary : const Color(0xFF1C1917),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final total = _parsedAmount + WalletService.transferFee;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transfere Lajan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF78350F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Voye lajan bay yon lòt itilizatè SagaEat',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Recipient
            TextField(
              controller: _recipientCtrl,
              decoration: InputDecoration(
                labelText: 'Destinatè',
                hintText: 'Email, username oswa ID',
                prefixIcon: const Icon(
                  Icons.person_search_rounded,
                  color: _kPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary, width: 2),
                ),
                labelStyle: const TextStyle(color: _kPrimary),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Montan (HTG)',
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: _kPrimary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary, width: 2),
                ),
                labelStyle: const TextStyle(color: _kPrimary),
              ),
            ),
            const SizedBox(height: 14),

            // Fee breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFB45309).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _feeRow('Montan', _parsedAmount),
                  const SizedBox(height: 4),
                  _feeRow(
                    'Frè transfert',
                    WalletService.transferFee,
                    note: '(frè platfòm)',
                  ),
                  const Divider(height: 12),
                  _feeRow('Total dedui', total, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Voye Lajan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(
    String label,
    double amount, {
    bool bold = false,
    String? note,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (note != null) ...[
              const SizedBox(width: 4),
              Text(
                note,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ],
        ),
        Text(
          '${amount.toStringAsFixed(0)} HTG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: bold ? const Color(0xFFB45309) : const Color(0xFF1C1917),
          ),
        ),
      ],
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

class _PayMethod {
  final String name;
  final IconData icon;
  final Color color;
  const _PayMethod(this.name, this.icon, this.color);
}

class _MethodTile extends StatelessWidget {
  final _PayMethod method;
  final VoidCallback onTap;

  const _MethodTile({required this.method, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: method.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: method.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, color: method.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: method.color,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: method.color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

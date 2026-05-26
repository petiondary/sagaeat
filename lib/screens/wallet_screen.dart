import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _kPrimary = Color(0xFFB45309);
  static const _kDark = Color(0xFF78350F);

  String _filter = 'all'; // all | deposit | purchase | refund
  DateTime? _startDate;
  DateTime? _endDate;
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  List<WalletTransaction> get _filtered {
    final all = WalletService.history;
    return all.where((t) {
      if (_filter != 'all' && t.type != _filter) return false;
      if (_startDate != null) {
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        if (t.date.isBefore(start)) return false;
      }
      if (_endDate != null) {
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
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
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kPrimary),
        ),
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
        if (_startDate != null && _startDate!.isAfter(picked)) _startDate = null;
      }
    });
  }

  void _clearDates() => setState(() {
        _startDate = null;
        _endDate = null;
      });

  void _showDepositSheet() {
    _amountCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DepositSheet(amountCtrl: _amountCtrl),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'jan', 'feb', 'mas', 'avr', 'me', 'jen',
      'jiy', 'out', 'sep', 'okt', 'nov', 'des'
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
      expandedHeight: 200,
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
                const SizedBox(height: 32),
                const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 36),
                const SizedBox(height: 8),
                const Text('Bous Mwen',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                ValueListenableBuilder<double>(
                  valueListenable: WalletService.balanceNotifier,
                  builder: (_, balance, _) => Text(
                    '${balance.toStringAsFixed(0)} HTG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showDepositSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Fè Depo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _kDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: const Text('Pòtmonè', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildFilterSection() {
    final filters = [
      ('all', 'Tout', Icons.swap_horiz_rounded),
      ('deposit', 'Depo', Icons.arrow_downward_rounded),
      ('purchase', 'Acha', Icons.shopping_bag_outlined),
      ('refund', 'Ranbousman', Icons.replay_rounded),
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
                    Icon(f.$3, size: 14,
                        color: selected ? Colors.white : _kPrimary),
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
                  fontSize: 13,
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
                child: const Icon(Icons.close_rounded,
                    color: Colors.red, size: 18),
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
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Color(0xFFD97706)),
              SizedBox(height: 12),
              Text('Okenn tranzaksyon',
                  style: TextStyle(
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              SizedBox(height: 4),
              Text('Chanje filtre ou pou wè plis',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _TransactionCard(
            transaction: items[i],
            formatDate: _formatDate,
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

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
          color: active ? const Color(0xFFB45309).withValues(alpha: 0.1) : Colors.white,
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

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final String Function(DateTime) formatDate;

  const _TransactionCard({
    required this.transaction,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    final isRefund = transaction.type == 'refund';
    final isPositive = transaction.amount > 0;

    final Color iconBg;
    final Color iconColor;
    final IconData icon;

    if (isDeposit) {
      iconBg = const Color(0xFFD1FAE5);
      iconColor = const Color(0xFF059669);
      icon = Icons.arrow_downward_rounded;
    } else if (isRefund) {
      iconBg = const Color(0xFFDBEAFE);
      iconColor = const Color(0xFF1D4ED8);
      icon = Icons.replay_rounded;
    } else {
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
                    fontSize: 14,
                    color: Color(0xFF1C1917),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  formatDate(transaction.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                if (transaction.orderId != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '# ${transaction.orderId}',
                    style: const TextStyle(
                      fontSize: 11,
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
              color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositSheet extends StatefulWidget {
  final TextEditingController amountCtrl;

  const _DepositSheet({required this.amountCtrl});

  @override
  State<_DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<_DepositSheet> {
  static const _kPrimary = Color(0xFFB45309);

  final _methods = [
    _PayMethod('Tranzak (Kaypa)', Icons.credit_card_rounded, Color(0xFF1D4ED8)),
    _PayMethod('MonCash', Icons.phone_android_rounded, Color(0xFFDC2626)),
    _PayMethod('Natcash', Icons.account_balance_rounded, Color(0xFF1E3A8A)),
    _PayMethod('Carte Bancaire', Icons.credit_score_rounded, Color(0xFF16A34A)),
  ];

  void _submit(String method, Color color) {
    final raw = widget.amountCtrl.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Antre yon montan valid pou kontinye'),
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
            const Text('Konfime Depo', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF1C1917), fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'W ap depoze '),
              TextSpan(
                text: '${amount.toStringAsFixed(0)} HTG',
                style: const TextStyle(fontWeight: FontWeight.w800, color: _kPrimary),
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
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Konfime'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
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
            controller: widget.amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
            decoration: InputDecoration(
              labelText: 'Montan (HTG)',
              prefixIcon: const Icon(Icons.attach_money_rounded,
                  color: _kPrimary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...(_methods.map((m) => _MethodTile(
                method: m,
                onTap: () => _submit(m.name, m.color),
              ))),
        ],
      ),
    );
  }
}

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
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: method.color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

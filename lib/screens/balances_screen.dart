import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../services/payment_service.dart';

class BalancesScreen extends StatelessWidget {
  final String? groupId;
  const BalancesScreen({super.key, this.groupId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final balances = groupId != null
        ? state.balancesForGroup(groupId!)
        : state.allBalances;

    final active = balances.where((b) => !b.settled).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (groupId == null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SplitSync',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('Hi, ${state.currentUserName} 👋',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppTheme.textMed)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      height: 1,
                      color: AppTheme.divider)),
            ],

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    if (groupId != null) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('← All Groups',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            if (groupId != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text('⚖️  Balances',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                ),
              ),

            if (groupId == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text('All Balances',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                ),
              ),

            if (active.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text('All settled up!',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      Text('No pending balances',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: AppTheme.textMed)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final b = active[i];
                    final isMe = b.from.id == 'me';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SplitCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        b.from.id == 'me'
                                            ? 'You'
                                            : b.from.name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.arrow_forward,
                                          size: 16, color: AppTheme.textMed),
                                    ),
                                    Text(b.to.id == 'me' ? 'You' : b.to.name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text(
                                  '₹${b.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isMe
                                        ? AppTheme.redAmount
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            if (isMe) ...[
                              const SizedBox(height: 4),
                              Text(
                                'You owe ${b.to.name} ₹${b.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: AppTheme.redAmount),
                              ),
                            ] else ...[
                              const SizedBox(height: 4),
                              Text(
                                '${b.from.name} owes you ₹${b.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: const Color(0xFF2E7D32)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () =>
                                  _showPaymentSheet(context, b, state),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? const LinearGradient(
                                          colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF9C94FF)
                                            ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      : null,
                                  color: isMe ? null : AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isMe
                                          ? Icons.payment
                                          : Icons.check_circle_outline,
                                      size: 16,
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isMe
                                          ? 'Pay ₹${b.amount.toStringAsFixed(0)} via UPI'
                                          : 'Settle Up ✓',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isMe
                                            ? Colors.white
                                            : AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: active.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(
      BuildContext context, Balance balance, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _UpiPaymentSheet(balance: balance, state: state),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPI Payment Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _UpiPaymentSheet extends StatefulWidget {
  final Balance balance;
  final AppState state;

  const _UpiPaymentSheet({required this.balance, required this.state});

  @override
  State<_UpiPaymentSheet> createState() => _UpiPaymentSheetState();
}

class _UpiPaymentSheetState extends State<_UpiPaymentSheet> {
  bool _isLoading = false;
  String? _loadingApp;

  Future<void> _handleUpiTap(
      BuildContext context, Map<String, dynamic> app) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingApp = app['name'] as String;
    });

    try {
      // Step 1: Create transaction on backend
      final txData = await PaymentService.createTransaction(
        fromUserId: 'me',
        toUserId: widget.balance.to.id,
        toName: widget.balance.to.name,
        amount: widget.balance.amount,
        groupId: widget.balance.groupId,
      );

      final txId = txData['transactionId'] as String;

      // Step 2: Build UPI deep link and launch UPI app
      final upiId = widget.balance.to.upiId ?? '${widget.balance.to.name.toLowerCase()}@upi';
      final launched = await PaymentService.launchUpiPayment(
        upiId: upiId,
        payeeName: widget.balance.to.name,
        amount: widget.balance.amount,
        transactionId: txId,
        upiScheme: app['scheme'] as String,
      );

      if (!mounted) return;

      // Step 3: After returning from UPI app — confirm payment
      if (launched) {
        // Small delay to let UPI app process
        await Future.delayed(const Duration(milliseconds: 500));

        final record = await PaymentService.confirmPayment(
          transactionId: txId,
          upiApp: app['name'] as String,
          amount: widget.balance.amount,
          paidTo: widget.balance.to.name,
        );

        // Settle balance in local state
        widget.state.settleBalance(widget.balance, record);

        if (!mounted) return;
        Navigator.pop(context); // Close bottom sheet

        // Step 4: Show success screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              record: record,
              payeeName: widget.balance.to.name,
              updatedBalance: 0.0,
            ),
          ),
        );
      } else {
        // UPI app not installed — mark as manual settle
        widget.state.settleBalance(
          widget.balance,
          PaymentRecord(
            transactionId: txId,
            amount: widget.balance.amount,
            paidTo: widget.balance.to.name,
            date: DateTime.now(),
            status: 'manual',
            upiApp: 'Manual',
          ),
        );
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Payment of ₹${widget.balance.amount.toStringAsFixed(0)} marked as settled!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay ₹${widget.balance.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'to ${widget.balance.to.name} ${widget.balance.to.emoji}',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.textMed),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // UPI ID display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, size: 16, color: Color(0xFF6C63FF)),
                const SizedBox(width: 8),
                Text(
                  widget.balance.to.upiId ??
                      '${widget.balance.to.name.toLowerCase()}@upi',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C63FF)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Choose UPI App',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMed)),
          const SizedBox(height: 12),

          ...upiApps.map((app) {
            final isThisLoading = _isLoading && _loadingApp == app['name'];
            return GestureDetector(
              onTap: () => _handleUpiTap(context, app),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isThisLoading
                      ? (app['color'] as Color).withOpacity(0.05)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isThisLoading
                        ? app['color'] as Color
                        : AppTheme.cardBorder,
                    width: isThisLoading ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (app['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isThisLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: app['color'] as Color,
                              ),
                            )
                          : Icon(app['icon'] as IconData,
                              color: app['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isThisLoading
                            ? 'Opening ${app['name']}...'
                            : app['name'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (!_isLoading)
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppTheme.textLight),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎉 Payment Success Screen
// ─────────────────────────────────────────────────────────────────────────────
class PaymentSuccessScreen extends StatefulWidget {
  final PaymentRecord record;
  final String payeeName;
  final double updatedBalance;

  const PaymentSuccessScreen({
    super.key,
    required this.record,
    required this.payeeName,
    required this.updatedBalance,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  bool _copied = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _scaleAnim = CurvedAnimation(
        parent: _scaleController, curve: Curves.elasticOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _slideController.forward());
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _copyTxId() {
    Clipboard.setData(ClipboardData(text: widget.record.transactionId));
    setState(() => _copied = true);
    Future.delayed(
        const Duration(seconds: 2), () => setState(() => _copied = false));
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // ✅ Animated checkmark
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C853).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 56),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Payment Successful!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You paid ${widget.payeeName}',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.white60),
            ),

            const SizedBox(height: 8),

            // Amount
            Text(
              '₹${widget.record.amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF69F0AE),
                height: 1.1,
              ),
            ),

            const SizedBox(height: 32),

            // Details card
            SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.receipt_long,
                        label: 'Transaction ID',
                        value: widget.record.transactionId,
                        trailing: GestureDetector(
                          onTap: _copyTxId,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _copied
                                ? const Icon(Icons.check,
                                    size: 16, color: Color(0xFF69F0AE))
                                : const Icon(Icons.copy,
                                    size: 16, color: Colors.white38),
                          ),
                        ),
                      ),
                      _divider(),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date & Time',
                        value: _formatDate(widget.record.date),
                      ),
                      _divider(),
                      _DetailRow(
                        icon: Icons.smartphone,
                        label: 'Paid via',
                        value: widget.record.upiApp,
                      ),
                      _divider(),
                      _DetailRow(
                        icon: Icons.account_balance_wallet,
                        label: 'Updated Balance',
                        value: widget.updatedBalance == 0.0
                            ? 'All settled up! 🎉'
                            : '₹${widget.updatedBalance.toStringAsFixed(0)} remaining',
                        valueColor: widget.updatedBalance == 0.0
                            ? const Color(0xFF69F0AE)
                            : Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: Colors.white12, indent: 16, endIndent: 16);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white38)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.white,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

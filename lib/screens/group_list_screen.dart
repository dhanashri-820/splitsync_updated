import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../widgets/shared_widgets.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SplitSync', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            Text('Hi, ${state.currentUserName} 👋', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMed)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded, color: AppTheme.textMed), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(child: _statCard('You Owe', '₹${state.totalIOwe.toStringAsFixed(0)}', AppTheme.redAmount)),
                const SizedBox(width: 15),
                Expanded(child: _statCard("You'll Receive", '₹${state.totalOwedToMe.toStringAsFixed(0)}', AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('YOUR GROUPS', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppTheme.textDark)),
                Row(children: [
                  const Icon(Icons.group_outlined, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text('${state.groups.length} groups', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed)),
                ]),
              ],
            ),
            const SizedBox(height: 15),
            ...state.groups.map((group) => _groupItem(group)),
            const SizedBox(height: 15),
            // Tip card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Tip: Tap a group to see expenses & balances. Use the + tab to add new expenses!',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(label.contains('Owe') ? Icons.arrow_outward : Icons.call_received, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed)),
          ]),
          const SizedBox(height: 8),
          Text(amount, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _groupItem(dynamic group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(group.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('${group.members.length} members', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed)),
            ],
          )),
          const Icon(Icons.chevron_right, color: AppTheme.textLight),
        ],
      ),
    );
  }
}

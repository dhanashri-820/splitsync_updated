import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  Group? _selectedGroup;
  AppMember? _paidBy;

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_selectedGroup == null && state.groups.isNotEmpty) {
      _selectedGroup = state.groups.first;
      _paidBy = _selectedGroup!.members.firstWhere((m) => m.id == 'me');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Add Expense', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded, color: AppTheme.textMed), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('GROUP'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Group>(
                  value: _selectedGroup,
                  isExpanded: true,
                  items: state.groups.map((g) => DropdownMenuItem(
                    value: g,
                    child: Text('${g.emoji} ${g.name} ${g.emoji}', style: GoogleFonts.poppins(fontSize: 14)),
                  )).toList(),
                  onChanged: (val) => setState(() {
                    _selectedGroup = val;
                    _paidBy = val?.members.firstWhere((m) => m.id == 'me');
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _label('DESCRIPTION'),
            const SizedBox(height: 8),
            _textField(_descController, 'e.g., Dinner, Taxi, Hotel...'),
            const SizedBox(height: 24),
            _label('AMOUNT (₹)'),
            const SizedBox(height: 8),
            _textField(_amountController, '0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _label('PAID BY'),
            const SizedBox(height: 12),
            if (_selectedGroup != null)
              Wrap(
                spacing: 10,
                children: _selectedGroup!.members.map((m) => GestureDetector(
                  onTap: () => setState(() => _paidBy = m),
                  child: Chip(
                    label: Text(m.id == 'me' ? 'You' : m.name, style: GoogleFonts.poppins(fontSize: 13, color: _paidBy == m ? Colors.white : AppTheme.textDark)),
                    avatar: Text(m.emoji),
                    backgroundColor: _paidBy == m ? AppTheme.primary : AppTheme.background,
                    side: BorderSide(color: _paidBy == m ? AppTheme.primary : AppTheme.cardBorder),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('Split equally among ${_selectedGroup?.members.length ?? 0} members',
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                if (_descController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  state.addExpense(Expense(
                    id: 'e${DateTime.now().millisecondsSinceEpoch}',
                    description: _descController.text,
                    amount: amount,
                    paidBy: _paidBy!,
                    splitAmong: _selectedGroup!.members,
                    date: DateTime.now(),
                    groupId: _selectedGroup!.id,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added!')));
                  _descController.clear();
                  _amountController.clear();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Add Expense', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight, letterSpacing: 1.1));

  Widget _textField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppTheme.textLight, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}

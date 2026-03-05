import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  String currentUserName = 'Aditi';
  String currentUserId = 'me';

  AppMember get me => AppMember(id: 'me', name: 'You', emoji: '😊');

  final List<Group> _groups = [
    Group(
      id: 'g1',
      name: 'Goa Trip',
      emoji: '🏖️',
      members: [
        AppMember(id: 'me', name: 'You', emoji: '😊', upiId: 'aditi@okaxis'),
        AppMember(id: 'm1', name: 'Arjun', emoji: '😎', phone: '+919876543210', upiId: 'arjun@okhdfc'),
        AppMember(id: 'm2', name: 'Priya', emoji: '🙂', phone: '+919876543211', upiId: 'priya@ybl'),
        AppMember(id: 'm3', name: 'Rahul', emoji: '😄', phone: '+919876543212', upiId: 'rahul@paytm'),
        AppMember(id: 'm4', name: 'Sneha', emoji: '🤩', phone: '+919876543213', upiId: 'sneha@upi'),
      ],
      expenses: [],
    ),
    Group(
      id: 'g2',
      name: 'Roommates',
      emoji: '🏠',
      members: [
        AppMember(id: 'me', name: 'You', emoji: '😊', upiId: 'aditi@okaxis'),
        AppMember(id: 'm5', name: 'Karan', emoji: '😁', phone: '+919876543214', upiId: 'karan@okicici'),
        AppMember(id: 'm6', name: 'Riya', emoji: '🙃', phone: '+919876543215', upiId: 'riya@upi'),
      ],
      expenses: [],
    ),
    Group(
      id: 'g3',
      name: 'Office Lunch',
      emoji: '🍕',
      members: [
        AppMember(id: 'me', name: 'You', emoji: '😊', upiId: 'aditi@okaxis'),
        AppMember(id: 'm7', name: 'Dev', emoji: '😏', phone: '+919876543216', upiId: 'dev@ybl'),
        AppMember(id: 'm8', name: 'Nisha', emoji: '🤗', phone: '+919876543217', upiId: 'nisha@paytm'),
        AppMember(id: 'm9', name: 'Aman', emoji: '😌', phone: '+919876543218', upiId: 'aman@okaxis'),
      ],
      expenses: [],
    ),
  ];

  List<Group> get groups => _groups;

  final List<Expense> _allExpenses = [];
  List<Expense> get allExpenses => _allExpenses;

  // Payment history
  final List<PaymentRecord> _paymentHistory = [];
  List<PaymentRecord> get paymentHistory => List.unmodifiable(_paymentHistory);

  List<Expense> expensesForGroup(String groupId) =>
      _allExpenses.where((e) => e.groupId == groupId).toList();

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _allExpenses.add(expense);
    notifyListeners();
  }

  // Calculate balances for a group
  List<Balance> balancesForGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    final expenses = expensesForGroup(groupId);

    final Map<String, double> net = {};
    for (final m in group.members) {
      net[m.id] = 0;
    }

    for (final e in expenses) {
      final perPerson = e.amount / e.splitAmong.length;
      net[e.paidBy.id] = (net[e.paidBy.id] ?? 0) + e.amount;
      for (final m in e.splitAmong) {
        net[m.id] = (net[m.id] ?? 0) - perPerson;
      }
    }

    final List<Balance> balances = [];
    final creditors = net.entries.where((e) => e.value > 0.01).toList();
    final debtors = net.entries.where((e) => e.value < -0.01).toList();

    for (final debtor in debtors) {
      for (final creditor in creditors) {
        if (debtor.value < -0.01 && creditor.value > 0.01) {
          final amount =
              debtor.value.abs().clamp(0.0, creditor.value).toDouble();
          if (amount > 0.01) {
            final fromMember =
                group.members.firstWhere((m) => m.id == debtor.key);
            final toMember =
                group.members.firstWhere((m) => m.id == creditor.key);
            balances.add(Balance(
              from: fromMember,
              to: toMember,
              amount: amount,
              groupId: groupId,
            ));
          }
        }
      }
    }
    return balances;
  }

  List<Balance> get allBalances {
    final List<Balance> all = [];
    for (final g in _groups) {
      all.addAll(balancesForGroup(g.id));
    }
    return all;
  }

  double get totalIOwe {
    return allBalances
        .where((b) => b.from.id == 'me' && !b.settled)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  double get totalOwedToMe {
    return allBalances
        .where((b) => b.to.id == 'me' && !b.settled)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  /// Settle balance and optionally attach payment record
  void settleBalance(Balance balance, [PaymentRecord? record]) {
    balance.settled = true;
    if (record != null) {
      balance.paymentRecord = record;
      _paymentHistory.add(record);
    }
    notifyListeners();
  }
}

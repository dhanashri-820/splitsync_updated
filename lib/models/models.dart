import 'package:flutter/material.dart';

class AppMember {
  final String id;
  final String name;
  final String? phone;
  final String? upiId; // NEW: UPI ID for payment
  final String emoji;
  bool isOnApp;

  AppMember({
    required this.id,
    required this.name,
    this.phone,
    this.upiId,
    required this.emoji,
    this.isOnApp = true,
  });
}

class Group {
  final String id;
  final String name;
  final String emoji;
  final List<AppMember> members;
  final List<Expense> expenses;

  Group({
    required this.id,
    required this.name,
    required this.emoji,
    required this.members,
    required this.expenses,
  });

  double get totalAmount => expenses.fold(0, (sum, e) => sum + e.amount);
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final AppMember paidBy;
  final List<AppMember> splitAmong;
  final DateTime date;
  final String groupId;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    required this.date,
    required this.groupId,
  });

  double get perPersonAmount => amount / splitAmong.length;
}

class Balance {
  final AppMember from;
  final AppMember to;
  final double amount;
  final String groupId;
  bool settled;
  PaymentRecord? paymentRecord; // NEW: attached after successful payment

  Balance({
    required this.from,
    required this.to,
    required this.amount,
    required this.groupId,
    this.settled = false,
    this.paymentRecord,
  });
}

// NEW: Payment record returned from backend
class PaymentRecord {
  final String transactionId;
  final double amount;
  final String paidTo;
  final DateTime date;
  final String status;
  final String upiApp;

  PaymentRecord({
    required this.transactionId,
    required this.amount,
    required this.paidTo,
    required this.date,
    required this.status,
    required this.upiApp,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      transactionId: json['transactionId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      paidTo: json['paidTo'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'success',
      upiApp: json['upiApp'] ?? '',
    );
  }
}

// emoji list for groups
const List<String> groupEmojis = [
  '🏖️', '🏠', '🍕', '🎉', '✈️', '🎮',
  '☕', '🛒', '🎬', '💼', '🎵', '🏋️',
];

// UPI apps
const List<Map<String, dynamic>> upiApps = [
  {'name': 'Google Pay', 'icon': Icons.credit_card, 'color': Color(0xFF4285F4), 'scheme': 'gpay'},
  {'name': 'PhonePe', 'icon': Icons.smartphone, 'color': Color(0xFF5F259F), 'scheme': 'phonepe'},
  {'name': 'Paytm', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF00BAF2), 'scheme': 'paytm'},
];

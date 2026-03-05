import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

class PaymentService {
  // 🔧 Change this to your deployed backend URL
  static const String _baseUrl = 'http://10.0.2.2:3000'; // Android emulator localhost
  // For real device: 'http://YOUR_LOCAL_IP:3000'
  // For production:  'https://your-backend.com'

  /// Step 1: Create transaction on backend, get transaction ID
  static Future<Map<String, dynamic>> createTransaction({
    required String fromUserId,
    required String toUserId,
    required String toName,
    required double amount,
    required String groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromUserId': fromUserId,
          'toUserId': toUserId,
          'toName': toName,
          'amount': amount,
          'groupId': groupId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: generate local transaction ID if backend unreachable
      final localTxId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      return {
        'transactionId': localTxId,
        'status': 'pending',
        'amount': amount,
        'toName': toName,
        'offline': true,
      };
    }
  }

  /// Step 2: Launch UPI deep link
  static Future<bool> launchUpiPayment({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionId,
    required String upiScheme,
  }) async {
    final amountStr = amount.toStringAsFixed(2);

    // Standard UPI deep link
    final upiUrl = Uri.parse(
      'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}'
      '&am=$amountStr&cu=INR&tn=SplitSync-$transactionId',
    );

    if (await canLaunchUrl(upiUrl)) {
      return await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Step 3: Confirm payment on backend after user returns
  static Future<PaymentRecord> confirmPayment({
    required String transactionId,
    required String upiApp,
    required double amount,
    required String paidTo,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/transactions/$transactionId/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': 'success',
          'upiApp': upiApp,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PaymentRecord.fromJson(data['transaction']);
      }
    } catch (_) {
      // Offline fallback
    }

    // Return local record if backend is unreachable
    return PaymentRecord(
      transactionId: transactionId,
      amount: amount,
      paidTo: paidTo,
      date: DateTime.now(),
      status: 'success',
      upiApp: upiApp,
    );
  }
}

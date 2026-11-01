import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tele/views/screens/components/config.dart';

class EvsPlusServices {
  /// Simulates the WaafiPay prompt on the customer's phone.
  /// A phone number ending in 0000 simulates a rejected payment.
  Future<Map<String, dynamic>> _mockPayment(String phone, double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.endsWith('0000')) {
      return {
        'status': false,
        'error': 'Customer rejected to authorize payment (test mode)',
        'message': 'Mock payment rejected',
      };
    }
    if (amount <= 0) {
      return {'status': false, 'error': 'Invalid amount', 'message': 'Mock payment failed'};
    }
    print('💳 MOCK PAYMENT: \$$amount from $phone approved (PAYMENT_MODE=mock)');
    return {'status': true, 'message': 'paid'};
  }

  String formatMerchantPhone(String phone) {
    if (phone.startsWith('+252')) {
      return phone.substring(1, 13);
    }
    final countryCodeIncluded =
        !phone.startsWith('+252') && !phone.startsWith('252');
    if (countryCodeIncluded) return '252$phone';
    return phone;
  }
  Future<Map<String, dynamic>> payByWaafiPay({
    required String phone,
    required double amount,
    required String merchantUid,
    required String apiUserId,
    required String apiKey,
    String description = 'Test',
    String invoiceId = '000',
    String referenceId = '00',
    String currency = 'USD',
  }) async {
    // Mock mode: used until real WaafiPay keys are added (PAYMENT_MODE=live in .env).
    if (Config.paymentMock) return _mockPayment(phone, amount);

    final sender = formatMerchantPhone(phone);
    final body = {
      "schemaVersion": "1.0",
      "requestId": "10111331033",
      "timestamp": DateTime.now().microsecondsSinceEpoch,
      "channelName": "WEB",
      "serviceName": "API_PURCHASE",
      "serviceParams": {
        "merchantUid": merchantUid,
        "apiUserId": apiUserId,
        "apiKey": apiKey,
        "paymentMethod": "mwallet_account",
        "payerInfo": {
          "accountNo": sender
        },
        "transactionInfo": {
          "referenceId": referenceId,
          "invoiceId": invoiceId,
          "amount": amount,
          "currency": currency,
          "description": description
        }
      }
    };
    
    final response = await http.post(
      Uri.parse('https://api.waafipay.net/asm'),
      headers: { "Content-type": "application/json"},
      body: jsonEncode(body)
    );
     final data = jsonDecode(response.body);
     print("EVS-PLUS RESPONSE ${data} and body ${data['responseMsg']}}");
    if(data['responseMsg'] != "RCS_SUCCESS"){
      String error = '';
      if(data['responseMsg'] == "RCS_NO_ROUTE_FOUND"){
        error = "Phone Number Not Found";
      }else if(data['responseMsg'] == "RCS_USER_REJECTED"){
        error = "Customer rejected to authorize payment";
      }else if(data['responseMsg'] == "Invalid_PIN") {
        error = "Customer rejected to authorize payment";
      }
      return {
        'status': false,
        'error': error.isNotEmpty ? error : data['params']['description'],
        'message': 'Maxaa u canceka gareese'

      };
    }
    return {'status': true, 'message': 'paid'};
  }
}

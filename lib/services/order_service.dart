import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart_item.dart';

class OrderService {
  OrderService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> submitOrder({
    required List<CartItem> items,
    required Map<String, dynamic> customer,
    required double subtotal,
    double deliveryFee = 0,
  }) async {
    final double total = subtotal + deliveryFee;
    final Map<String, dynamic> payload = <String, dynamic>{
      'items': items
          .map((CartItem item) => <String, dynamic>{
                'id': item.product.id,
                'name': item.product.name,
                'unitPrice': item.product.price,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
              })
          .toList(),
      'customer': customer,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };

    try {
      final http.Response response = await _client.post(
        Uri.parse(ordersEndpoint),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (error, stackTrace) {
      debugPrint('Order submission failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}

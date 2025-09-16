import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart_item.dart';

class OrderService {
  OrderService({
    http.Client? client,
    List<String> endpoints = storeCheckoutEndpoints,
    this.requestTimeout = const Duration(seconds: 12),
  })  : _client = client ?? http.Client(),
        _endpoints = endpoints
            .where((String url) => url.trim().isNotEmpty)
            .map(Uri.parse)
            .toList(growable: false);

  final http.Client _client;
  final List<Uri> _endpoints;
  final Duration requestTimeout;

  Future<bool> submitOrder({
    required List<CartItem> items,
    required Map<String, dynamic> customer,
    required double subtotal,
    double deliveryFee = 0,
  }) async {
    final double total = subtotal + deliveryFee;
    final String currencyCode =
        items.isNotEmpty ? items.first.product.currencyCode : 'USD';
    final String currencySymbol =
        items.isNotEmpty ? items.first.product.currencySymbol : 'US\$';
    final String currencySuffix =
        items.isNotEmpty ? items.first.product.currencySuffix : '';
    final Map<String, dynamic> payload = <String, dynamic>{
      'items': items
          .map((CartItem item) => <String, dynamic>{
                'id': item.product.id,
                'name': item.product.name,
                'unitPrice': item.product.price,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
                'permalink': item.product.permalink,
                'imageUrl': item.product.imageUrl,
              })
          .toList(),
      'customer': customer,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'currency': <String, String>{
        'code': currencyCode,
        'symbol': currencySymbol,
        'suffix': currencySuffix,
      },
    };

    if (_endpoints.isEmpty) {
      debugPrint('Order submission failed: no checkout endpoints configured.');
      return false;
    }

    final List<String> failures = <String>[];

    for (final Uri endpoint in _endpoints) {
      try {
        final http.Response response = await _client
            .post(
              endpoint,
              headers: const <String, String>{
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(requestTimeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
        failures.add('HTTP ${response.statusCode} from ${endpoint.toString()}');
      } on TimeoutException catch (_) {
        failures.add('Timeout contacting ${endpoint.toString()}');
      } catch (Object error, StackTrace stackTrace) {
        failures.add('Error contacting ${endpoint.toString()}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    debugPrint('Order submission failed: ${failures.join('; ')}');
    return false;
  }
}

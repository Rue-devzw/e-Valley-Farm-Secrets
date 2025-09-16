import 'package:flutter/material.dart';

const double bikerDeliveryFee = 5.0;

/// Base URL for the live Valley Farm Secrets WooCommerce Store API.
const String storeApiBaseUrl =
    'https://www.valleyfarmsecrets.com/store/wp-json/wc/store';

/// Endpoint that accepts checkout submissions for the Valley Farm Secrets store.
const String ordersEndpoint =
    'https://www.valleyfarmsecrets.com/store/wp-json/wc/store/checkout';

/// Fallback image used when a product does not expose a dedicated thumbnail.
const String placeholderImageUrl =
    'https://images.unsplash.com/photo-1484981137413-6f0d4f3b3326?auto=format&fit=crop&w=800&q=80';

const Color primaryGreen = Color(0xFF5B8C51);
const Color accentGold = Color(0xFFE0B341);

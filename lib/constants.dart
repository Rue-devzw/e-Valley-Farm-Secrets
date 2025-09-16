import 'package:flutter/material.dart';

const double bikerDeliveryFee = 5.0;

/// Candidate base URLs for the live Valley Farm Secrets WooCommerce Store API.
///
/// The store is hosted under `/store`, but the underlying WordPress REST API can
/// be exposed either from the root domain or the `/store` subdirectory depending
/// on the server configuration. Trying both gives the app a better chance of
/// reaching the live catalogue without requiring a code change.
const List<String> storeApiBaseUrls = <String>[
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store',
];

/// Checkout endpoints derived from [storeApiBaseUrls]. The first responsive
/// endpoint will be used when attempting to submit an order.
const List<String> storeCheckoutEndpoints = <String>[
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store/checkout',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store/checkout',
];

/// Fallback image used when a product does not expose a dedicated thumbnail.
const String placeholderImageUrl =
    'https://images.unsplash.com/photo-1484981137413-6f0d4f3b3326?auto=format&fit=crop&w=800&q=80';

const Color primaryGreen = Color(0xFF5B8C51);
const Color accentGold = Color(0xFFE0B341);

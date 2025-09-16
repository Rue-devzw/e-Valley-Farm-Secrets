import 'package:flutter/material.dart';

const double bikerDeliveryFee = 5.0;

/// Candidate base URLs for the live Valley Farm Secrets WooCommerce Store API.
///
/// The WordPress installation serves the REST API both from the root domain and
/// the `/store` subdirectory. Additionally, newer WooCommerce deployments expose
/// the versioned `wc/store/v1` endpoints while older builds still answer under
/// `wc/store`. Listing each permutation allows the app to seamlessly fall back
/// without additional configuration when the server is upgraded or moved.
const List<String> storeApiBaseUrls = <String>[
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store/v1',
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store/v1',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store',
];

/// Checkout endpoints derived from [storeApiBaseUrls]. The first responsive
/// endpoint will be used when attempting to submit an order.
const List<String> storeCheckoutEndpoints = <String>[
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store/v1/checkout',
  'https://www.valleyfarmsecrets.com/store/wp-json/wc/store/checkout',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store/v1/checkout',
  'https://www.valleyfarmsecrets.com/wp-json/wc/store/checkout',
];

/// Fallback image used when a product does not expose a dedicated thumbnail.
const String placeholderImageUrl =
    'https://images.unsplash.com/photo-1484981137413-6f0d4f3b3326?auto=format&fit=crop&w=800&q=80';

const Color primaryGreen = Color(0xFF5B8C51);
const Color accentGold = Color(0xFFE0B341);

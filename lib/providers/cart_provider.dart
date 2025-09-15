import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = <String, CartItem>{};

  List<CartItem> get items {
    final List<CartItem> sorted = _items.values.toList()
      ..sort((CartItem a, CartItem b) => a.product.name.compareTo(b.product.name));
    return sorted;
  }

  int get itemCount => _items.values.fold<int>(0, (int total, CartItem item) => total + item.quantity);

  double get subtotal =>
      _items.values.fold<double>(0, (double total, CartItem item) => total + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  void addItem(Product product) {
    final CartItem? existing = _items[product.id];
    if (existing != null) {
      _items[product.id] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    if (_items.remove(product.id) != null) {
      notifyListeners();
    }
  }

  void updateQuantity(Product product, int quantity) {
    if (!_items.containsKey(product.id)) {
      return;
    }
    if (quantity <= 0) {
      _items.remove(product.id);
    } else {
      _items[product.id] = _items[product.id]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  CartItem? itemFor(Product product) => _items[product.id];
}

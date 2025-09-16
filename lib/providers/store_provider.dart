import 'package:flutter/foundation.dart';

import '../data/store_data.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/store_service.dart';

class StoreProvider extends ChangeNotifier {
  StoreProvider({StoreService? service}) : _service = service ?? StoreService();

  final StoreService _service;

  final List<Category> _categories = <Category>[];
  final List<Product> _products = <Product>[];

  bool _isLoading = false;
  bool _hasAttemptedInitialLoad = false;
  String? _statusMessage;
  String _currencyCode = 'USD';
  String _currencySymbol = 'US\$';
  String _currencySuffix = '';

  List<Category> get categories => List<Category>.unmodifiable(_categories);
  List<Product> get products => List<Product>.unmodifiable(_products);

  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  String get currencySuffix => _currencySuffix;
  String get currencyLabel {
    if (_currencySymbol.trim().isNotEmpty) {
      return _currencySymbol.trim();
    }
    if (_currencySuffix.trim().isNotEmpty) {
      return _currencySuffix.trim();
    }
    return _currencyCode;
  }

  Future<void> ensureLoaded() async {
    if (_hasAttemptedInitialLoad || _isLoading) {
      return;
    }
    await load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (!forceRefresh && _hasAttemptedInitialLoad) {
      return;
    }
    _isLoading = true;
    _hasAttemptedInitialLoad = true;
    notifyListeners();

    try {
      final StoreCatalog catalog = await _service.fetchCatalog();
      final List<Category> sortedCategories = List<Category>.from(catalog.categories)
        ..sort((Category a, Category b) => a.name.compareTo(b.name));
      _categories
        ..clear()
        ..addAll(sortedCategories);
      _products
        ..clear()
        ..addAll(catalog.products);
      _currencyCode = catalog.currencyCode;
      _currencySymbol = catalog.currencySymbol;
      _currencySuffix = catalog.currencySuffix;
      _statusMessage = null;
    } on StoreServiceException catch (error, stackTrace) {
      debugPrint('StoreProvider failed to load catalog: $error');
      debugPrintStack(stackTrace: stackTrace);
      _statusMessage =
          'Using offline catalogue. ${error.displayMessage}';
      _applyOfflineFallback();
    } catch (Object error, StackTrace stackTrace) {
      debugPrint('StoreProvider hit an unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _statusMessage =
          'Unable to load the live Valley Farm Secrets catalogue. Showing offline data.';
      _applyOfflineFallback();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() => load(forceRefresh: true);

  void _applyOfflineFallback() {
    _categories
      ..clear()
      ..addAll(storeCategories);
    _products
      ..clear()
      ..addAll(storeProducts);
    _currencyCode = 'USD';
    _currencySymbol = 'US\$';
    _currencySuffix = '';
  }
}

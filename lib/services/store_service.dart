import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/sub_category.dart';

class StoreCatalog {
  const StoreCatalog({
    required this.categories,
    required this.products,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySuffix,
  });

  final List<Category> categories;
  final List<Product> products;
  final String currencyCode;
  final String currencySymbol;
  final String currencySuffix;
}

class StoreService {
  StoreService({http.Client? client, this.baseUrl = storeApiBaseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const int _pageSize = 100;

  Future<StoreCatalog> fetchCatalog() async {
    final List<Category> categories = await _fetchCategories();
    final _ProductResponse productResponse =
        await _fetchProducts(categories: categories);
    return StoreCatalog(
      categories: categories,
      products: productResponse.products,
      currencyCode: productResponse.currencyCode,
      currencySymbol: productResponse.currencySymbol,
      currencySuffix: productResponse.currencySuffix,
    );
  }

  Future<List<Category>> _fetchCategories() async {
    final Uri uri = Uri.parse('$baseUrl/products/categories?per_page=$_pageSize');
    final http.Response response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StoreServiceException(
        'Failed to load categories (HTTP ${response.statusCode})',
      );
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    final Map<int, Map<String, dynamic>> raw = <int, Map<String, dynamic>>{};
    final Map<int, List<SubCategory>> children = <int, List<SubCategory>>{};

    for (final dynamic entry in decoded) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final int? id = _asInt(entry['id']);
      if (id == null) {
        continue;
      }
      raw[id] = entry;
      final int parentId = _asInt(entry['parent']) ?? 0;
      if (parentId != 0) {
        final String name = (entry['name'] as String? ?? '').trim();
        children.putIfAbsent(parentId, () => <SubCategory>[])
          ..add(
            SubCategory(
              id: id.toString(),
              name: name.isEmpty ? 'Category $id' : name,
            ),
          );
      }
    }

    final List<Category> categories = <Category>[];
    for (final MapEntry<int, Map<String, dynamic>> entry in raw.entries) {
      final int parentId = _asInt(entry.value['parent']) ?? 0;
      if (parentId != 0 && raw.containsKey(parentId)) {
        continue;
      }
      final int id = entry.key;
      final String name = (entry.value['name'] as String? ?? '').trim();
      final String description = (entry.value['description'] as String? ?? '').trim();
      categories.add(
        Category(
          id: id.toString(),
          name: name.isEmpty ? 'Category $id' : name,
          description: description,
          subCategories: List<SubCategory>.unmodifiable(children[id] ?? <SubCategory>[]),
        ),
      );
    }

    categories.sort((Category a, Category b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<_ProductResponse> _fetchProducts({required List<Category> categories}) async {
    final Map<String, Category> categoryById = <String, Category>{
      for (final Category category in categories) category.id: category,
    };
    final List<Product> products = <Product>[];
    String currencyCode = 'USD';
    String currencySymbol = 'US\$';
    String currencySuffix = '';

    int page = 1;
    while (true) {
      final Uri uri = Uri.parse('$baseUrl/products?per_page=$_pageSize&page=$page');
      final http.Response response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StoreServiceException(
          'Failed to load products (HTTP ${response.statusCode})',
        );
      }
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      if (decoded.isEmpty) {
        break;
      }
      for (final dynamic entry in decoded) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final Product? product = _mapProduct(
          entry,
          categoryById: categoryById,
          categories: categories,
        );
        if (product != null) {
          products.add(product);
          currencyCode = product.currencyCode;
          currencySymbol = product.currencySymbol;
          currencySuffix = product.currencySuffix;
        }
      }
      if (decoded.length < _pageSize) {
        break;
      }
      page += 1;
    }

    return _ProductResponse(
      products: products,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      currencySuffix: currencySuffix,
    );
  }

  Product? _mapProduct(
    Map<String, dynamic> json, {
    required Map<String, Category> categoryById,
    required List<Category> categories,
  }) {
    final dynamic idValue = json['id'];
    if (idValue == null) {
      return null;
    }
    final String id = idValue.toString();
    final String name = (json['name'] as String? ?? '').trim();
    if (name.isEmpty) {
      return null;
    }

    final Map<String, dynamic> prices =
        (json['prices'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final int minorUnits = _asInt(prices['currency_minor_unit']) ?? 2;
    final double divisor = math.pow(10, minorUnits).toDouble();

    double? parsePrice(dynamic value) {
      if (value == null) {
        return null;
      }
      final String normalised = value.toString().replaceAll(',', '');
      if (normalised.isEmpty) {
        return null;
      }
      final double? parsed = double.tryParse(normalised);
      if (parsed == null) {
        return null;
      }
      if (normalised.contains('.')) {
        return parsed;
      }
      return parsed / divisor;
    }

    double price = parsePrice(prices['price']) ?? 0;
    final double? regularPrice = parsePrice(prices['regular_price']);
    final double? salePrice = parsePrice(prices['sale_price']);

    bool onSpecial = false;
    double? oldPrice;
    if (salePrice != null && salePrice > 0 && (regularPrice ?? price) > salePrice) {
      oldPrice = regularPrice ?? price;
      price = salePrice;
      onSpecial = true;
    } else if (regularPrice != null && regularPrice > price) {
      oldPrice = regularPrice;
    }

    final String currencyCode =
        (prices['currency_code'] as String? ?? 'USD').toUpperCase();
    final String currencySymbol =
        (prices['currency_prefix'] as String? ?? prices['currency_symbol'] as String? ?? '')
            .toString();
    final String currencySuffix =
        (prices['currency_suffix'] as String? ?? '').toString();

    final List<Map<String, dynamic>> categoryEntries =
        (json['categories'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();

    String categoryId = 'uncategorized';
    String? subCategoryId;
    if (categoryEntries.isNotEmpty) {
      Map<String, dynamic>? topLevel;
      for (final Map<String, dynamic> entry in categoryEntries) {
        final int parentId = _asInt(entry['parent']) ?? 0;
        if (parentId == 0) {
          topLevel = entry;
          break;
        }
      }
      topLevel ??= categoryEntries.first;
      final int topLevelId = _asInt(topLevel['id']) ?? 0;
      final int parentId = _asInt(topLevel['parent']) ?? 0;
      if (parentId != 0) {
        categoryId = parentId.toString();
        subCategoryId = topLevelId.toString();
        _ensureCategoryExists(
          categoryId: categoryId,
          source: categoryEntries.firstWhere(
            (Map<String, dynamic> entry) => (_asInt(entry['id']) ?? 0) == parentId,
            orElse: () => topLevel!,
          ),
          categoryById: categoryById,
          categories: categories,
        );
      } else {
        categoryId = topLevelId.toString();
        for (final Map<String, dynamic> entry in categoryEntries) {
          final int potentialParent = _asInt(entry['parent']) ?? 0;
          if (potentialParent == topLevelId) {
            subCategoryId = (_asInt(entry['id']) ?? 0).toString();
            break;
          }
        }
        _ensureCategoryExists(
          categoryId: categoryId,
          source: topLevel!,
          categoryById: categoryById,
          categories: categories,
        );
      }
    } else {
      _ensureCategoryExists(
        categoryId: categoryId,
        source: <String, dynamic>{'name': 'Uncategorized'},
        categoryById: categoryById,
        categories: categories,
      );
    }

    final List<Map<String, dynamic>> images =
        (json['images'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();
    String imageUrl = placeholderImageUrl;
    if (images.isNotEmpty) {
      final String candidate = (images.first['src'] as String? ?? '').trim();
      if (candidate.isNotEmpty) {
        imageUrl = candidate;
      }
    }

    final String shortDescription = _cleanHtml(json['short_description'] as String?);
    final String description = shortDescription.isNotEmpty
        ? shortDescription
        : _cleanHtml(json['description'] as String?);

    return Product(
      id: id,
      name: name,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
      price: price,
      oldPrice: oldPrice,
      unit: 'Per item',
      imageUrl: imageUrl,
      description: description.isNotEmpty ? description : null,
      onSpecial: onSpecial,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      currencySuffix: currencySuffix,
      permalink: (json['permalink'] as String?)?.trim(),
    );
  }

  void _ensureCategoryExists({
    required String categoryId,
    required Map<String, dynamic> source,
    required Map<String, Category> categoryById,
    required List<Category> categories,
  }) {
    if (categoryById.containsKey(categoryId)) {
      return;
    }
    final String name = (source['name'] as String? ?? '').trim();
    final String description = (source['description'] as String? ?? '').trim();
    final Category category = Category(
      id: categoryId,
      name: name.isEmpty ? 'Category $categoryId' : name,
      description: description,
    );
    categories.add(category);
    categoryById[categoryId] = category;
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _cleanHtml(String? value) {
    if (value == null) {
      return '';
    }
    final String withoutTags = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _ProductResponse {
  const _ProductResponse({
    required this.products,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencySuffix,
  });

  final List<Product> products;
  final String currencyCode;
  final String currencySymbol;
  final String currencySuffix;
}

class StoreServiceException implements Exception {
  StoreServiceException(this.message);

  final String message;

  @override
  String toString() => 'StoreServiceException: $message';
}


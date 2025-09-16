import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: cart.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.shopping_basket_outlined, size: 56, color: colors.primary),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Browse the store and add a few items to start your order.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Start Shopping'),
                  ),
                ],
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: 4,
                      width: 48,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          final CartItem item = cart.items[index];
                          return _CartItemRow(item: item);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Subtotal', style: theme.textTheme.titleMedium),
                        Text(
                          cart.formatAmount(cart.subtotal),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCheckout();
                        },
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.read<CartProvider>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.product.imageUrl,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                width: 72,
                height: 72,
                color: colors.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image_outlined, color: colors.outline),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove item',
                    icon: const Icon(Icons.close),
                    onPressed: () => cart.removeItem(item.product),
                  ),
                ],
              ),
              Text(item.product.unit, style: theme.textTheme.bodySmall?.copyWith(color: colors.outline)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _QuantityControl(
                    quantity: item.quantity,
                    onDecrease: () => cart.updateQuantity(item.product, item.quantity - 1),
                    onIncrease: () => cart.addItem(item.product),
                  ),
                  Text(
                    item.product.formatPrice(item.subtotal),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrease,
        ),
        Text('$quantity', style: theme.textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

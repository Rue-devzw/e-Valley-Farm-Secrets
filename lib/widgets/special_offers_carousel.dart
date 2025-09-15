import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_card.dart';

class SpecialOffersCarousel extends StatelessWidget {
  const SpecialOffersCarousel({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Special Offers',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text('${products.length} deals'),
              avatar: const Icon(Icons.local_fire_department_outlined, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (BuildContext context, int index) {
              final Product product = products[index];
              return SizedBox(
                width: 240,
                child: ProductCard(product: product),
              );
            },
          ),
        ),
      ],
    );
  }
}
